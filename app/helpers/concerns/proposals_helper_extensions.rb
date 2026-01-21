# frozen_string_literal: true

module ProposalsHelperExtensions
  extend ActiveSupport::Concern

  included do
    # rubocop:disable Rails/HelperInstanceVariable
    def proposal_has_costs?
      @proposal.cost.present?
    end
    # rubocop:enable Rails/HelperInstanceVariable
  end
end
