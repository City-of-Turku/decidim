# frozen_string_literal: true

module Turku
  class TunnistamoMetadataCollector < Decidim::Tunnistamo::Verification::MetadataCollector
    def metadata
      super.tap do |data|
        if authentication_method == "turku_suomifi"
          data.merge!(
            birthdate: raw_info[:birthdate],
            municipality_code: raw_info.dig(:address, :municipality_code),
            municipality_name: raw_info.dig(:address, :municipality_name),
            postal_code: raw_info.dig(:address, :postal_code)
          )
        elsif authentication_method == "turku_opasid"
          # TODO: The OpasID is so far untested and not known what kind of data
          #       it contains
        end
      end
    end
  end
end
