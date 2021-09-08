# frozen_string_literal: true

module Decidim
  module Admin
    class VoteReminderJob < ApplicationJob
      queue_as :vote_reminder

      def perform(user, orders)
        return unless user
        return if orders.blank?

        ::Decidim::Admin::VoteReminderMailer.vote_reminder(user, orders).deliver_now
      end
    end
  end
end
