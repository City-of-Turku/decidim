# frozen_string_literal: true

module Turku
  class TunnistamoAuthenticator < Decidim::Tunnistamo::Authentication::Authenticator
    def validate!
      super

      if has_security_denial?
        raise Decidim::Tunnistamo::Authentication::ValidationError.new(
          "Information security denial",
          :security_denial
        )
      end

      true
    end

    private

    def has_security_denial?
      oauth_raw_info.dig(:address, :turvakielto) == "1"
    end
  end
end
