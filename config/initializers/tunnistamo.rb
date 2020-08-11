# frozen_string_literal: true

require "turku/tunnistamo_authenticator"
require "turku/tunnistamo_metadata_collector"

Decidim::Tunnistamo.configure do |config|
  config.scope = %i[openid email profile address]
  config.authenticator_class = Turku::TunnistamoAuthenticator
  config.metadata_collector_class = Turku::TunnistamoMetadataCollector
end
