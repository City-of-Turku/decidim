# frozen_string_literal: true

module Turku
  module Budgets
    module Workflows
      # This Workflow is for managing the Asukasbudjetti voting where all people can
      # vote in the "Entire Turku" area and in addition, they select one area
      # of their choice from the rest.
      #
      # This also provides a special "sticky" method for the
      # voting pipeline to make some budgets "sticky" (i.e. always selected).
      class Asukasbudjetti < Decidim::Budgets::Workflows::Base
        STICKY_SCOPE_CODE = "SUURALUE-01-KOKOTURKU"

        def highlighted?(_resource)
          false
        end

        # rubocop:disable Lint/UnusedMethodArgument
        def vote_allowed?(resource, consider_progress: true)
          return false if voted?(resource)
          return true if sticky?(resource)

          voted.reject { |budget| budget.scope&.code == STICKY_SCOPE_CODE }.none?
        end
        # rubocop:enable Lint/UnusedMethodArgument

        # Defines whether a budget should be marked as "sticky" or not.
        def sticky?(resource)
          return false unless resource.scope

          resource.scope&.code == STICKY_SCOPE_CODE
        end

        def progress
          @progress ||= begin
            info_array = orders.values.reject { |order_info| sticky?(order_info[:order].budget) }
            info_array.map { |order_info| order_info[:order].budget if order_info[:status] == :progress }.compact
          end
        end
      end
    end
  end
end
