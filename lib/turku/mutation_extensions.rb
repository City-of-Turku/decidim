# frozen_string_literal: true

module Turku
  module MutationExtensions
    # Public: Extends a type with `decidim-proposals`'s fields.
    #
    # type - A GraphQL::BaseType to extend.
    #
    # Returns nothing.
    def self.included(type)
      type.field :proposal, Decidim::Proposals::ProposalMutationType, null: false do
        description "A proposal"

        argument :id, GraphQL::Types::ID, "The proposal's id", required: true
        argument :state, GraphQL::Types::String, "The proposal's state", required: true
        argument :answer_content, GraphQL::Types::JSON, "The proposal's answer", required: true
      end
    end

    def proposal(id:, state:, answer_content:)
      proposal = Decidim::Proposals::Proposal.find(id)

      params = {
        internal_state: state,
        answer: YAML.safe_load(answer_content),
        component_id: proposal.component.id.to_s
      }

      form = Decidim::Proposals::Admin::ProposalAnswerForm.from_params(
        params
      ).with_context(
        current_component: proposal.component
      )
      Decidim::Proposals::Admin::AnswerProposal.call(form, proposal) do
        on(:ok) do
          return proposal
        end
        on(:invalid) do
          return GraphQL::ExecutionError.new(
            form.errors.full_messages.join(", ")
          )
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.proposals.admin.proposals.answer.invalid")
        )
      end
    end
  end
end
