# frozen_string_literal: true

require "decidim/api/activity_type"

module Turku
  module QueryExtensions
    def self.included(type)
      type.field :activity, [Decidim::Turku::ActivityType], null: false do
        argument :user_id, GraphQL::Types::ID, "The user's ID", required: false
        argument :oid, GraphQL::Types::String, "The user's OID", required: false
      end
    end

    def activity(user_id: nil, oid: nil)
      if oid && context[:current_user].admin?
        user = Decidim::Identity.find_by(turku_oid: oid).user
        return activities(user, %w(private-only public-only all))
      end

      activities(Decidim::User.find(user_id), %w(public-only all))
    end

    private

    def activities(user, visibility)
      ::Decidim::ActionLog.where(
        user: user,
        visibility: visibility,
        organization: context[:current_organization]
      )
    end

    def find_user(id, oid)
      return Decidim::Identity.find_by(turku_oid: oid).user if oid

      Decidim::User.find(id)
    end
  end
end
