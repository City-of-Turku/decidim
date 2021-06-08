# frozen_string_literal: true

module Turku
  class TunnistamoMetadataCollector < Decidim::Tunnistamo::Verification::MetadataCollector
    def metadata
      super.tap do |data|
        case authentication_method
        when "turku_suomifi"
          # Suomi.fi
          data.merge!(
            birthdate: raw_info[:birthdate],
            municipality_code: raw_info.dig(:address, :municipality_code),
            municipality_name: raw_info.dig(:address, :municipality_name),
            postal_code: raw_info.dig(:address, :postal_code)
          )
        when "opas_adfs"
          # Students ADFS
          data.merge!(
            # The role can be one of "student", "teacher" or nil/empty.
            role: raw_info[:school_role]
          )
        when "axiell_aurora"
          # Library card
          data.merge!(birthdate: raw_info[:birthdate])
        end
      end
    end
  end
end
