# frozen_string_literal: true

module Decidim
  module Admin
    class VoteReminderJob < ApplicationJob
      queue_as :vote_reminder

      def perform(vote_reminders)
        vote_reminders.each do |reminder|
          next unless time_to_remind?(reminder)

          reminder.update!(times: reminder.times << Time.current)
          Decidim::Admin::VoteReminderDeliveryJob.perform_later(reminder)
        end
      end

      private

      def time_to_remind?(reminder)
        intervals = Array(Rails.application.config.reminder_times)
        return false if intervals.length <= reminder.times.length
        return false if intervals[reminder.times.length] > Time.current - reminder.orders.last.created_at

        true
      end
    end
  end
end
