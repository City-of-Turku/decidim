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
        next unless component.current_settings.votes == "enabled"

        budgets = Decidim::Budgets::Budget.where(component: component)
        orders = Decidim::Budgets::Order.where(budget: budgets, checked_out_at: nil)

        orders.each do |order|
          reminder = ::Turku::VotingReminder.find_or_create_by!(user: order.user)
          reminder.orders << order
          reminders << reminder
        end
      end

      reminders.each do |reminder|
        Turku::VoteReminderJob.perform_now(reminder.user, reminder.orders)
      end
    end
  end
end
