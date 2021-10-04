# frozen_string_literal: true

module Decidim
  module Turku
    class ActivityType < Decidim::Api::Types::BaseObject
      graphql_name "Activity"
      description "An activity."

      field :id, GraphQL::Types::ID, "Internal ID for this activity", null: false
      field :resource_type, GraphQL::Types::String, "Resource type", null: true
      field :resource, GraphQL::Types::JSON, "Resource", null: true
      field :component, GraphQL::Types::JSON, "Component", null: true
      field :participatory_space, GraphQL::Types::JSON, "Participatory space", null: true
      field :action, GraphQL::Types::String, "Action", null: true
      field :extra, GraphQL::Types::JSON, "Extra", null: true
      field :visibility, GraphQL::Types::String, "Visibility", null: true
    end
  end
end
