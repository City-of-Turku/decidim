# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalMutationType < GraphQL::Schema::Object
      graphql_name "ProposalMutation"
      description "a proposal which includes its available mutations"

      field :id, ID, null: false

      field :answer, Decidim::Proposals::ProposalType, null: true do
        description "Answer to a proposal"

        argument :state, String, description: "The answer status in which the proposal is in. Can be one of 'accepted', 'rejected' or 'evaluating'", required: true
        argument :answer_content, GraphQL::Types::JSON, description: "The answer feedback for the status for this proposal", required: false
      end
    end
  end
end
