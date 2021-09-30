# frozen_string_literal: true

module Decidim
  module Admin
    class VoteReminderJob < ApplicationJob
      queue_as :vote_reminder

      def perform(user, order_ids)
        return unless user
        return if order_ids.blank?

        ::Decidim::Admin::VoteReminderMailer.vote_reminder(user, order_ids).deliver_now
      end
    end
  end
end
