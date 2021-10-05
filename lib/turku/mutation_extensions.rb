# frozen_string_literal: true

module Turku
  module MutationExtensions
    # Public: Adds possibility to answer proposals via API.
    #
    # type - A GraphQL::BaseType to extend.
    #
    # Returns nothing.
    def self.included(type)
      type.field :proposal, Decidim::Proposals::ProposalMutationType, null: false do
        description "A proposal"

        argument :id, GraphQL::Types::ID, "The proposal's id", required: true
      end
    end

    def proposal(id:, locale: Decidim.default_locale, toggle_translations: false)
      I18n.locale = locale.presence
      RequestStore.store[:toggle_machine_translations] = toggle_translations
      Decidim::Proposals::Proposal.find(id)
    end
  end
end
