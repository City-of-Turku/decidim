# frozen_string_literal: true

# Usage: bundle exec rake turku:budgets:remind

def time_to_remind?(reminder)
  intervals = Array(Rails.application.config.reminder_times)

  return false if intervals.length <= reminder.times.length
  return false if intervals[reminder.times.length] > Time.current - reminder.orders.last.created_at

  true
end

# Send email reminders to users who have started voting process but haven't actually voted (pressed "vote" button)
namespace :turku do
  namespace :budgets do
    desc "Send reminders to users who haven't checked out voting"
    task remind: :environment do
      components = Decidim::Component.where(manifest_name: "budgets")

      reminders = []
      components.each do |component|
        generator = Decidim::Budgets::Admin::VotingReminderGenerator.new(component)
        reminders.push(*generator.generate)
      end

      reminders.each do |reminder|
        next unless time_to_remind?(reminder)

        reminder.remind!
      end
    end
  end
end
