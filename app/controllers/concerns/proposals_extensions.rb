# frozen_string_literal: true

# Customizes the proposals controller
module ProposalsExtensions
  extend ActiveSupport::Concern

  included do
    private

    def default_filter_params
      {
        search_text_cont: "",
        activity: "all",
        related_to: "",
        with_any_state: %w(accepted evaluating rejected state_not_published),
        with_any_category: default_filter_category_params,
        with_any_origin: default_filter_origin_params,
        with_any_scope: default_filter_scope_params,
        type: "all"
      }
    end
  end
end
