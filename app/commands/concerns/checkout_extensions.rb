# frozen_string_literal: true

module CheckoutExtensions
  extend ActiveSupport::Concern

  included do
    def call
      return broadcast(:invalid, order) unless checkout!

      create_log(order)

      broadcast(:ok, order)
    end

    private

    def create_log(order)
      Decidim::ActionLogger.log(
        "checkout",
        order.user,
        order,
        nil,
        {
          visibility: "private-only",
          budget: order.budget
        }
      )
    end
  end
end
