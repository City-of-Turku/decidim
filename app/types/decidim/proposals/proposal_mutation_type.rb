# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalMutationType < GraphQL::Schema::Object
      graphql_name "ProposalMutation"
      description "a proposal which includes its available mutations"

      field :id, GraphQL::Types::ID, "Proposal's unique ID", null: false

      field :answer, Decidim::Proposals::ProposalType, null: true do
        description "Answer to a proposal"

        argument :state, GraphQL::Types::String, description: "The answer status in which the proposal is in. Can be one of 'accepted', 'rejected' or 'evaluating'", required: true
        argument :answer_content, GraphQL::Types::JSON, description: "The answer feedback for the status for this proposal", required: false
        argument :cost, GraphQL::Types::Float, description: "Estimated cost of the proposal", required: false
        argument :cost_report, GraphQL::Types::JSON, description: "Report on expenses", required: false
        argument :execution_period, GraphQL::Types::JSON, description: "Report on the execution perioid", required: false
      end

      def answer(state:, answer_content: nil, cost: nil, cost_report: nil, execution_period: nil)
        enforce_permission_to :create, :proposal_answer, proposal: object

        params = {
          internal_state: state,
          answer: answer_content || object.answer,
          component_id: object.component.id.to_s,
          proposal_id: object.id,
          cost: cost || object.cost,
          cost_report: cost_report || object.cost_report,
          execution_period: execution_period || object.execution_period
        }

        form = Decidim::Proposals::Admin::ProposalAnswerForm.from_params(
          params
        ).with_context(
          current_component: object.component,
          current_organization: object.organization,
          current_user: current_user
        )

        Decidim::Proposals::Admin::AnswerProposal.call(form, object) do
          on(:ok) do
            return object
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

      private

      def current_user
        context[:current_user]
      end

      def enforce_permission_to(action, subject, extra_context = {})
        raise Decidim::Proposals::ActionForbidden unless allowed_to?(action, subject, extra_context)
      end

      def allowed_to?(action, subject, extra_context = {}, user = current_user)
        scope ||= :admin
        permission_action = Decidim::PermissionAction.new(scope: scope, action: action, subject: subject)

        permission_class_chain.inject(permission_action) do |current_permission_action, permission_class|
          permission_class.new(
            user,
            current_permission_action,
            permissions_context.merge(extra_context)
          ).permissions
        end.allowed?
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end

      def permission_class_chain
        [
          object.component.manifest.permissions_class,
          object.participatory_space.manifest.permissions_class,
          ::Decidim::Admin::Permissions,
          ::Decidim::Permissions
        ]
      end

      def permissions_context
        {
          current_settings: object.component.current_settings,
          component_settings: object.component.settings,
          current_organization: object.organization,
          current_component: object.component
        }
      end

      class ::Decidim::Proposals::ActionForbidden < StandardError
      end
    end
  end
end
