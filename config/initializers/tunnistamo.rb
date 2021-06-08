# frozen_string_literal: true

require "turku/tunnistamo_authenticator"
require "turku/tunnistamo_metadata_collector"

Decidim::Tunnistamo.configure do |config|
  config.scope = [:openid, :email, :profile, :address]
  config.authenticator_class = Turku::TunnistamoAuthenticator
  config.metadata_collector_class = Turku::TunnistamoMetadataCollector
  config.workflow_configurator = lambda do |workflow|
    workflow.expires_in = 0.minutes
    workflow.action_authorizer = "TurkuTunnistamoActionAuthorizer"
    workflow.options do |options|
      options.attribute :allow_suomifi, type: :boolean, required: false
      options.attribute :allow_opasid, type: :boolean, required: false
      options.attribute :allow_library_card, type: :boolean, required: false
      options.attribute :minimum_age, type: :integer, required: false
      options.attribute :suomifi_municipalities, type: :string, required: false
      options.attribute :opasid_role, type: :string, required: false
    end
  end
end
