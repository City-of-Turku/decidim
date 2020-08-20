# frozen_string_literal: true

module Turku
  class TunnistamoMetadataCollector < Decidim::Tunnistamo::Verification::MetadataCollector
    def metadata
      super.tap do |data|
        if authentication_method == "turku_suomifi"
          # Suomi.fi
          data.merge!(
            birthdate: raw_info[:birthdate],
            municipality_code: raw_info.dig(:address, :municipality_code),
            municipality_name: raw_info.dig(:address, :municipality_name),
            postal_code: raw_info.dig(:address, :postal_code)
          )
        elsif authentication_method == "opas_adfs"
          # Students ADFS
          data.merge!(role: student_role)
        elsif authentication_method == "axiell_aurora"
          # Library card
          data.merge!(birthdate: raw_info[:birthdate])
        end
      end
    end

    private

    def student_role
      return "student" if raw_info[:is_student]

      nil
    end
  end
end
