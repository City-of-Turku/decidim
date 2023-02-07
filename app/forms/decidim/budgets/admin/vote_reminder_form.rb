# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class VoteReminderForm < Decidim::Form
        attribute :reminder_amount

        def reminder_amount
          @reminder_amount ||= if voting_enabled?
                                 user_ids = []
                                 unfinished_orders.each do |order|
                                   next unless order.user
                                   next if order.user.email.blank?

                                   reminder = Decidim::Budgets::VoteReminder.find_by(component: current_component, user: order.user)
                                   next if reminder && reminder.times.present? && reminder.times.last > 24.hours.ago

                                   user_ids << order.user.id
                                 end
                                 user_ids.uniq.count
                               else
                                 0
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
