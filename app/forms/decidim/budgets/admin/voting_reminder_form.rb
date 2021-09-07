# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class VotingReminderForm < Decidim::Form
        attribute :reminder_amount

        def reminder_amount
          @reminder_amount ||= begin
            return 0 unless voting_enabled?

            user_ids = unfinished_orders.map do |order|
              order.user.id
            end
            user_ids.uniq.count
          end
        end

        def unfinished_orders
          @unfinished_orders ||= Decidim::Budgets::Order.where(budget: budgets, checked_out_at: nil)
        end

        def voting_enabled?
          current_component.current_settings.votes == "enabled"
        end

        private

        def budgets
          @budgets ||= Decidim::Budgets::Budget.where(component: current_component)
        end
      end
    end
  end
end
