# frozen_string_literal: true

module Turku
  class VotingReminder < ApplicationRecord
    self.table_name = "turku_voting_reminders"
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    belongs_to :component, foreign_key: "decidim_component_id", class_name: "Decidim::Component"
    has_many :orders, class_name: "Decidim::Budgets::Order", dependent: :nullify, foreign_key: "turku_voting_reminder_id"

    def remind!
      update!(times: times << Time.current)
      Turku::VoteReminderJob.perform_now(user, orders)
    end
  end
end
