# frozen_string_literal: true

require "turku/api/activity_type"

module Turku
  module Api
    module QueryExtensions
      def self.included(type)
        user_field = type.own_fields["user"]
        user_field.argument :oid, GraphQL::Types::String, "The UID of the participant", required: false
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
