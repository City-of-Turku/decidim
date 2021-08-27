# frozen_string_literal: true

module Turku
  class VoteReminderJob < ApplicationJob
    queue_as :vote_reminder

    def perform(user, orders)
      return unless user
      return unless orders

      VoteReminderMailer.vote_reminder(user, orders).deliver_now
    end
  end
end
