# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when admin sends vote reminders.
      class CreateVoteReminders < Decidim::Command
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless voting_enabled?

          reminders.each(&:remind!)

          broadcast(:ok, reminders)
        end

        private

        attr_reader :form

        def send_remind?(reminder)
          return true if reminder.times.empty?

          reminder.times.last < Time.current - 24.hours
        end

        def reminders
          @reminders ||= begin
            @reminders = generator.generate
            @reminders.select { |r| send_remind?(r) }
          end
        end

        def generator
          @generator ||= Decidim::Budgets::Admin::VoteReminderGenerator.new(current_component)
        end

        def current_component
          form.current_component
        end

        def voting_enabled?
          form.voting_enabled?
        end
      end
    end
  end
end
