# frozen_string_literal: true

# Used to anonymize certain details of the voting results so that the individual
# voters cannot be tracked. This is always different for each run.
ANONYMIZER_SALT = SecureRandom.hex(64)

namespace :turku do
  # Export budgeting votes.
  #
  # Usage:
  #   bundle exec rake turku:export_budget_votes[1,tmp/budget_votes.xls]
  desc "Export budgeting votes to an Excel file."
  task :export_budget_votes, [:component_id, :filename] => [:environment] do |t, args|
    component_id = args[:component_id]
    filename = args[:filename]

    export_component(component_id, filename)
  end

  private

  def export_component(component_id, filename)
    c = Decidim::Component.find_by(id: component_id)
    if c.nil? || c.manifest_name != "budgets"
      puts "Invalid component provided: #{component_id}."
      return
    end
    unless filename
      puts "Please provide an export file path."
      return
    end
    if File.exist?(filename)
      puts "File already exists at: #{filename}"
      return
    end

    # Go through all votes in the component
    budgets = {}
    Decidim::Budgets::Budget.where(component: c).each do |budget|
      votes = []
      project_votes = {}
      project_pending_votes = {}

      Decidim::Budgets::Order.where(budget: budget).each do |order|
        total = 0
        project_ids = []
        order.projects.each do |p|
          total += p.budget_amount
          project_ids << p.id

          project_votes[p.id] ||= 0
          project_pending_votes[p.id] ||= 0

          if order.checked_out?
            project_votes[p.id] += 1
          else
            project_pending_votes[p.id] += 1
          end
        end

        metadata = user_metadata(order.user)

        identity = nil
        postal_code = nil
        age = nil
        if metadata
          identity = metadata[:identity]
          postal_code = metadata[:postal_code]
          age = metadata[:age]
        end

        impersonated = Decidim::ImpersonationLog.where(user: order.user).any?

        user_hash = Digest::MD5.hexdigest("#{ANONYMIZER_SALT}:#{order.user.id}")
        order_hash = Digest::MD5.hexdigest("#{ANONYMIZER_SALT}:#{order.id}")

        votes << {
          user_hash: user_hash,
          impersonated_user: impersonated ? 1 : 0,
          order_hash: order_hash,
          voted_project_ids: project_ids.join(","),
          voted_projects_count: order.projects.count,
          voted_amount: total,
          identity: identity,
          postal_code: postal_code,
          age: age.to_s,
          finished: order.checked_out? ? 1 : 0,
          checked_out_at: order.checked_out_at
        }
      end

      projects = project_votes.map do |project_id, votes|
        project = Decidim::Budgets::Project.find(project_id)
        title = project.title.dig("fi") || project.title.dig("en")
        pending_votes = project_pending_votes[project_id]

        {id: project.id, title: title, budget: project.budget_amount, votes: votes, pending_votes: pending_votes}
      end

      budgets["#{budget.title["fi"]} - Votes"] = votes
      budgets["#{budget.title["fi"]} - Projects"] = projects
    end

    write_excel(budgets, filename)
  end

  def user_metadata(user)
    authorization = Decidim::Authorization.where(
      user: user,
      name: "tunnistamo_idp"
    ).order(:created_at).last
    unless authorization
      authorization = Decidim::Authorization.where(
        user: user,
        name: "turku_documents_authorization_handler"
      ).order(:created_at).last
    end
    return unless authorization

    rawdata = authorization.metadata

    data = begin
      case authorization.name
      when "tunnistamo_idp"
        case rawdata["service"]
        when "turku_suomifi"
          {
            identity: "Suomi.fi",
            date_of_birth: Date.strptime(rawdata["birthdate"], "%Y-%m-%d"),
            postal_code: rawdata["postal_code"]
          }
        when "opas_adfs"
          {
            identity: "OpasID",
            date_of_birth: nil,
            postal_code: nil
          }
        end
      when "turku_documents_authorization_handler"
        {
          identity: "Document - #{rawdata["document_type"]}",
          date_of_birth: Date.strptime(rawdata["date_of_birth"], "%Y-%m-%d"),
          postal_code: rawdata["postal_code"]
        }
      end
    end

    # During testing, there may be unknown authorizations.
    unless data
      return {
        identity: nil,
        date_of_birth: nil,
        postal_code: nil,
        age: nil
      }
    end

    data[:age] = nil
    if data[:date_of_birth]
      now = Time.now.utc.to_date
      dob = data[:date_of_birth]
      data[:age] = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    end

    data
  end

  # Takes an array of hashes containing the data to put on each sheet.
  # Each of the values in the hash needs to contain an array of the row data for
  # that sheet.
  # Each of the items in the row data array needs to be a hash containing the
  # data for each row. The hash keys are the column headers for that sheet.
  #
  # Example:
  # {
  #   export: [
  #     {id: 1, name: "Mark", nickname: "mark"}
  #   ],
  #   extra: [
  #     {id: 1, code: "123"}
  #   ]
  # }
  #
  # hashes containing the export rows.
  # The hash keys need to be the names of the columns.
  def write_excel(sheets, filename)
    return if sheets.length < 1

    require "spreadsheet"

    book = Spreadsheet::Workbook.new
    sheets.each do |sheetname, data|
      next if data.length < 1

      headers = data.first.keys

      sheet = book.create_worksheet
      sheet.name = sheetname.to_s
      sheet.row(0).default_format = Spreadsheet::Format.new(
        weight: :bold,
        pattern: 1,
        pattern_fg_color: :xls_color_14,
        horizontal_align: :center
      )
      sheet.row(0).replace headers.map(&:to_s)
      headers.length.times.each do |index|
        sheet.column(index).width = 20
      end
      data.each_with_index do |resource, index|
        sheet.row(index + 1).replace(headers.map { |header| resource[header] })
      end
    end

    book.write filename
  end
end
