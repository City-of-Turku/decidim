# frozen_string_literal: true

module CreateOmniauthRegistrationExtensions
  extend ActiveSupport::Concern

  included do
    def existing_identity
      @existing_identity ||= begin
        identity = ::Decidim::Identity.find_by(
          user: organization.users.entire_collection,
          provider: form.provider,
          uid: form.uid
        )

        identity.update(turku_oid: anonymized_oid) if identity && !identity.turku_oid && anonymized_oid
        identity
      end
    end

    private

    alias_method :create_identity_orig_turku, :create_identity unless private_method_defined?(:create_identity_orig_turku)

    def create_identity
      identity = create_identity_orig_turku
      identity.update(turku_oid: anonymized_oid) if !identity.turku_oid && anonymized_oid
      identity
    end

    def anonymized_oid
      @anonymized_oid ||= begin
        turku_oid = form.raw_data.dig(:extra, :raw_info, :oid)
        if turku_oid
          salt = Rails.application.secrets.secret_key_base
          Digest::MD5.hexdigest("OID:#{turku_oid}:#{salt}")
        end
      end
    end
  end
end
