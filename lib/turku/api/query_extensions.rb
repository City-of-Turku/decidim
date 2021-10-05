# frozen_string_literal: true

require "turku/api/activity_type"

module Turku
  module Api
    module QueryExtensions
      def self.included(type)
        # TODO: Move activity under the user record
        # type.field :activity, [Decidim::Turku::ActivityType], null: false do
        #   argument :user_id, GraphQL::Types::ID, "The user's ID", required: false
        #   argument :oid, GraphQL::Types::String, "The user's OID", required: false
        # end

        user_field = type.own_fields["user"]
        user_field.argument :oid, GraphQL::Types::String, "The UID of the participant", required: false
        # type.add_field :activity, [Turku::ActivityType, { null: true }], "User's activities", null: false
      end

      def user(id: nil, oid: nil, nickname: nil)
        if oid
          raise Decidim::ActionForbidden unless context[:current_user].admin?

          id = Decidim::Identity.find_by(turku_oid: pseudoanonymized(oid))&.user&.id&.to_s || id
        end

        Decidim::Core::UserEntityFinder.new.call(object, { id: id, nickname: nickname }, context)
      end

      private

      def pseudoanonymized(oid)
        Digest::MD5.hexdigest("OID:#{oid}:#{Rails.application.secrets.secret_key_base}")
      end
    end
  end
end
