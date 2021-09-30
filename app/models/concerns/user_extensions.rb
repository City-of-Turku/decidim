# frozen_string_literal: true

module UserExtensions
  extend ActiveSupport::Concern

  included do
    has_many :vote_reminders, foreign_key: "decidim_user_id", class_name: "Decidim::Budgets::VoteReminder", dependent: :destroy
  end
end
