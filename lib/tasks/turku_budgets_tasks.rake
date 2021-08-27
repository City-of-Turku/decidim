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
        next unless component.current_settings.votes == "enabled"

        budgets = Decidim::Budgets::Budget.where(component: component)
        orders = Decidim::Budgets::Order.where(budget: budgets, checked_out_at: nil)

        orders.each do |order|
          reminder = ::Turku::VotingReminder.find_or_create_by!(user: order.user, component: component)
          reminder.orders << order
          reminders << reminder
        end
      end

      reminders.each do |reminder|
        reminder.orders.each do |order|
          reminder.orders.delete(order.id) if order.checked_out_at.present?
        end

        next unless time_to_remind?(reminder)

        Turku::VoteReminderJob.perform_now(reminder.user, reminder.orders)
        reminder.update(times: reminder.times << Time.current)
        reminder.times << Time.current
      end
    end
  end
end
