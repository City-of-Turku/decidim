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
  end
end
