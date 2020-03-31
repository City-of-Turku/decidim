require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DecidimTurku
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.time_zone = "Europe/Helsinki"

    # Configure an application wide address suffix to pass to the geocoder.
    # This is to make sure that the addresses are not incorrectly mapped outside
    # of the wanted area.
    config.address_suffix = "Turku, Finland"

    # Sending address for mails
    config.mailer_sender = "noreply@turku.fi"

    config.search_indexing = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
