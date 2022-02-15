# frozen_string_literal: true

# Customizes the line items controller
module LineItemsExtensions
  extend ActiveSupport::Concern

  included do
    before_action :set_help_modal

    private

    def set_help_modal
      @show_help_modal = Decidim::Budgets::Order.find_by(user: current_user, budget: budget).blank?
    end
  end
end
