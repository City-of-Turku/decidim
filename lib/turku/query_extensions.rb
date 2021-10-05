# frozen_string_literal: true

require "decidim/api/activity_type"

module Turku
  module QueryExtensions
    def self.included(type)
      # TODO: Move activity under the user record
      type.field :activity, [Decidim::Turku::ActivityType], null: false do
        argument :user_id, GraphQL::Types::ID, "The user's ID", required: false
        argument :oid, GraphQL::Types::String, "The user's OID", required: false
      end

      user_field = type.own_fields["user"]
      user_field.argument :uid, GraphQL::Types::String, "The UID of the participant", required: false
    end

    def activity(user_id: nil, oid: nil)
      if oid && context[:current_user].admin?
        user = Decidim::Identity.find_by(turku_oid: oid).user
        return activities(user, %w(private-only public-only all))
      end

      activities(Decidim::User.find(user_id), %w(public-only all))
    end

    def user(id: nil, uid: nil, nickname: nil)
      if uid
        # TODO: Make sure the logged in user has system admin rights
        # TODO: If not, throw an exception
      end

      # TODO: Implement the customized UserEntityFinder
      # Turku::UserEntityFinder.new.call(object, { id: id, uid: uid, nickname: nickname }, context)
      Decidim::Core::UserEntityFinder.new.call(object, { id: id, nickname: nickname }, context)
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
