# frozen_string_literal: true

module Turku
  class VotingReminder < ApplicationRecord
    self.table_name = "turku_voting_reminders"
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    has_many :orders, class_name: "Decidim::Budgets::Order", dependent: :destroy, foreign_key: "turku_voting_reminder_id"
  end
end
