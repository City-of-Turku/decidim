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

          broadcast(:ok, "foo")
        end

        private

        attr_reader :form

        def current_component
          form.current_component
        end
      end
    end
  end
end
