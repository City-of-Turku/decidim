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
  task :export_budget_votes, [:component_id, :filename] => [:environment] do |_t, args|
    component_id = args[:component_id]
    filename = args[:filename]

    export_component(component_id, filename)
  end

  private

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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

      projects = project_votes.map do |project_id, single_votes|
        project = Decidim::Budgets::Project.find(project_id)
        title = project.title["fi"] || project.title["en"]
        pending_votes = project_pending_votes[project_id]

        {
          id: project.id,
          title: title,
          budget: project.budget_amount,
          votes: single_votes,
          pending_votes: pending_votes
        }
      end

      budgets["#{budget.title["fi"]} - Votes"] = votes
      budgets["#{budget.title["fi"]} - Projects"] = projects
    end

    write_excel(budgets, filename)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/CyclomaticComplexity
  def user_metadata(user)
    authorization = Decidim::Authorization.where(
      user: user,
      name: "tunnistamo_idp"
    ).order(:created_at).last || Decidim::Authorization.where(
      user: user,
      name: "turku_documents_authorization_handler"
    ).order(:created_at).last
    return unless authorization

    rawdata = authorization.metadata

    data = case authorization.name
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
      data[:age] = now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1
    end

    data
  end
  # rubocop:enable Metrics/CyclomaticComplexity

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
    return if sheets.empty?

    require "rubyXL"
    require "rubyXL/convenience_methods/font"
    require "rubyXL/convenience_methods/workbook"
    require "rubyXL/convenience_methods/worksheet"

    book = RubyXL::Workbook.new
    book.worksheets.delete_at(0)
    sheets.each do |sheetname, data|
      next if data.empty?

      headers = data.first.keys

      sheet = book.add_worksheet(sheetname)
      sheet.change_row_fill(0, "c0c0c0")
      sheet.change_row_bold(0, true)
      sheet.change_row_horizontal_alignment(0, "center")
      headers.each_with_index do |header, index|
        sheet.change_column_width(index, 20)
        sheet.add_cell(0, index, header.to_s)
      end
      data.each_with_index do |resource, rowi|
        headers.each_with_index do |header, coli|
          sheet.add_cell(rowi + 1, coli, resource[header])
        end
      end
    end

    book.write filename
  end
end
