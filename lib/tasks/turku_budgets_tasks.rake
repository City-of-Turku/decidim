# frozen_string_literal: true

# Usage: bundle exec rake turku:budgets:remind

# Send email reminders to users who have started voting process but haven't actually voted (pressed "vote" button)
namespace :turku do
  namespace :budgets do
    desc "Send reminders to users who haven't checked out voting"
    task remind: :environment do
      components = Decidim::Component.where(manifest_name: "budgets")

      reminders = []
      components.each do |component|
        generator = Decidim::Budgets::Admin::VoteReminderGenerator.new(component)
        reminders.push(*generator.generate)
      end

      Decidim::Admin::VoteReminderJob.perform_later(reminders)
    end

    desc "Calculate some statistics about the confirmed votes"
    task :confirmed_votes_stats, [:component_id, :filename] => [:environment] do |_t, args|
      component_id = args[:component_id]
      filename = args[:filename]

      component = Decidim::Component.find_by(id: component_id, manifest_name: "budgets")
      unless component
        puts "Invalid component provided: #{component_id}."
        return
      end
      if File.exist?(filename)
        puts "File already exists at: #{filename}"
        return
      end

      require "rubyXL"
      require "rubyXL/convenience_methods/font"
      require "rubyXL/convenience_methods/workbook"
      require "rubyXL/convenience_methods/worksheet"

      book = RubyXL::Workbook.new
      sheet = book.worksheets[0]
      %w(
        confirmed
        created_at_date
        created_at_time
        checked_out_date
        checked_out_time
        remind1_date
        remind1_time
        remind2_date
        remind2_time
        remind3_date
        remind3_time
        remind4_date
        remind4_time
        remind5_date
        remind5_time
      ).each_with_index do |header, index|
        sheet.add_cell(0, index, header)
      end
      Decidim::Budgets::Order.joins(:budget).where(
        decidim_budgets_budgets: { decidim_component_id: component }
      ).order(:created_at).each_with_index do |order, index|
        rowdata = [
          order.checked_out_at.present? ? "1" : "0",
          order.created_at.strftime("%Y-%m-%d"),
          order.created_at.strftime("%H:%M"),
          order.checked_out_at&.strftime("%Y-%m-%d"),
          order.checked_out_at&.strftime("%H:%M")
        ]
        Decidim::Budgets::VoteReminder.where(user: order.user).order(:id).each do |reminder|
          reminder.times.sort.each do |remind_time|
            rowdata += [
              remind_time.strftime("%Y-%m-%d"),
              remind_time.strftime("%H:%M")
            ]
          end
        end

        rowdata.each_with_index do |celldata, celli|
          sheet.add_cell(index + 1, celli, celldata)
        end
      end

      book.write filename
    end
  end
end
