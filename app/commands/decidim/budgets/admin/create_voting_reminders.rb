# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when admin sends vote reminders.
      class CreateVotingReminders < Rectify::Command
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) if form.invalid?

          reminders.each(&:remind!)

          broadcast(:ok, reminders)
        end

        private

        attr_reader :form

        def time_to_remind?(reminder)
          return true if reminder.times.empty?

          reminder.times.last < Time.current - 24.hours
        end

        def reminders
          @reminders ||= begin
            @reminders = generator.generate
            @reminders.select { |r| time_to_remind?(r) }
          end
        end

        def generator
          @generator ||= Decidim::Budgets::Admin::VotingReminderGenerator.new(current_component)
        end

        def current_component
          form.current_component
        end
      end
    end
  end
end
