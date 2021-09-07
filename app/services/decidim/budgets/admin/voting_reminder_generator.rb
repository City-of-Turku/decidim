# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class VotingReminderGenerator
        def initialize(component)
          @component = component
        end

        def generate
          return unless voting_enabled?

          reminders = []
          budgets = Decidim::Budgets::Budget.where(component: @component)
          orders = Decidim::Budgets::Order.where(budget: budgets, checked_out_at: nil)

          orders.each do |order|
            reminder = ::Turku::VotingReminder.find_or_create_by!(user: order.user, component: @component)
            reminder.orders << order
            reminders << reminder
          end

          # Clean checked out orders
          reminders.each do |reminder|
            reminder.orders.each do |order|
              reminder.orders.delete(order.id) if order.checked_out_at.present?
            end
          end

          reminders
        end

        private

        def voting_enabled?
          @component.current_settings.votes == "enabled"
        end
      end
    end
  end
end
