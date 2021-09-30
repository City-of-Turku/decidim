# frozen_string_literal: true

module Decidim
  module Budgets
    class VoteReminder < ApplicationRecord
      self.table_name = "decidim_vote_reminders"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      belongs_to :component, foreign_key: "decidim_component_id", class_name: "Decidim::Component"
      has_many :orders, class_name: "Decidim::Budgets::Order", dependent: :nullify, foreign_key: "decidim_vote_reminder_id"

      def remind!
        update!(times: times << Time.current)
        order_ids = orders.pluck(:id)
        ::Decidim::Admin::VoteReminderJob.perform_later(user, order_ids)
      end
    end
  end
end
