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
          raise Decidim::ActionForbidden unless current_user_admin?

          id = Decidim::Identity.find_by(turku_oid: pseudoanonymized(oid))&.user&.id&.to_s || id
        end
        return admin_find_user(id: id, nickname: nickname) if current_user_admin?

        Decidim::Core::UserEntityFinder.new.call(object, { id: id, nickname: nickname }, context)
      end

      private

      def current_user_admin?
        context[:current_user]&.admin?
      end

      def pseudoanonymized(oid)
        Digest::MD5.hexdigest("OID:#{oid}:#{Rails.application.secrets.secret_key_base}")
      end

      def admin_find_user(**args)
        filters = {
          organization: context[:current_organization]
        }
        args.each do |argument, value|
          next if value.blank?

          v = value.to_s
          v = v[1..-1] if value.starts_with? "@"
          filters[argument.to_sym] = v
        end

        Decidim::UserBaseEntity
          .confirmed
          .not_blocked
          .entire_collection
          .find_by(**filters)
      end
    end
  end
end
