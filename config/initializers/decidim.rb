# frozen_string_literal: true

Decidim.configure do |config|
  config.application_name = "Turku Asukasbudjetti"
  config.mailer_sender = Rails.application.config.mailer_sender

  # Change these lines to set your preferred locales
  config.default_locale = :fi
  config.available_locales = [:fi, :sv, :en]

  # Maps configuration
  if Rails.application.secrets.maps.present? && Rails.application.secrets.maps[:static_provider].present?
    static_provider = Rails.application.secrets.maps[:static_provider]
    dynamic_provider = Rails.application.secrets.maps[:dynamic_provider]
    dynamic_url = Rails.application.secrets.maps[:dynamic_url]
    static_url = Rails.application.secrets.maps[:static_url]
    static_url = "https://image.maps.hereapi.com/mia/v3/base/mc/overlay" if static_provider == "here" && static_url.blank?
    config.maps = {
      provider: static_provider,
      api_key: Rails.application.secrets.maps[:static_api_key],
      static: { url: static_url },
      dynamic: {
        provider: dynamic_provider,
        api_key: Rails.application.secrets.maps[:dynamic_api_key]
      }
    }
    config.maps[:geocoding] = { host: Rails.application.secrets.maps[:geocoding_host], use_https: true } if Rails.application.secrets.maps[:geocoding_host]
    config.maps[:dynamic][:tile_layer] = {}
    config.maps[:dynamic][:tile_layer][:url] = dynamic_url if dynamic_url
    config.maps[:dynamic][:tile_layer][:attribution] = Rails.application.secrets.maps[:attribution] if Rails.application.secrets.maps[:attribution]
    if Rails.application.secrets.maps[:extra_vars].present?
      vars = URI.decode_www_form(Rails.application.secrets.maps[:extra_vars])
      vars.each do |key, value|
        # perform a naive type conversion
        config.maps[:dynamic][:tile_layer][key] = case value
                                                  when /^true$|^false$/i
                                                    value.downcase == "true"
                                                  when /\A[-+]?\d+\z/
                                                    value.to_i
                                                  else
                                                    value
                                                  end
      end
    end
  end

  # Cookie/data consent
  config.consent_categories = [
    {
      slug: "essential",
      mandatory: true,
      items: [
        {
          type: "cookie",
          name: "_session_id"
        },
        {
          type: "cookie",
          name: Decidim.consent_cookie_name
        },
        {
          type: "local_storage",
          name: "pwaInstallPromptSeen"
        }
      ]
    },
    {
      slug: "preferences",
      mandatory: false,
      items: [
        {
          type: "cookie",
          name: "SOCS"
        },
        {
          type: "cookie",
          name: "VISITOR_PRIVACY_METADATA"
        },
        {
          type: "cookie",
          name: "VISITOR_INFO1_LIVE"
        },
        {
          type: "cookie",
          name: "YSC"
        }
      ]
    },
    {
      slug: "analytics",
      mandatory: false,
      items: [
        {
          type: "cookie",
          name: "VISITOR_INFO1_LIVE"
        }
      ]
    },
    {
      slug: "marketing",
      mandatory: false,
      items: [
        {
          type: "cookie",
          name: "__Secure-ENID"
        },
        {
          type: "cookie",
          name: "AEC"
        },
        {
          type: "cookie",
          name: "DV"
        },
        {
          type: "cookie",
          name: "VISITOR_INFO1_LIVE"
        }
      ]
    }
  ]

  # By default in Decidim this is set as 0. We need to have unconfirmed
  # access so that participant can verify his/her email.
  config.unconfirmed_access_for = 1000.days

  # Geocoder configurations if you want to customize the default geocoding
  # settings. The maps configuration will manage which geocoding service to use,
  # so that does not need any additional configuration here. Use this only for
  # the global geocoder preferences.
  # config.geocoder = {
  #   # geocoding service request timeout, in seconds (default 3):
  #   timeout: 5,
  #   # set default units to kilometers:
  #   units: :km,
  #   # caching (see https://github.com/alexreisner/geocoder#caching for details):
  #   cache: Redis.new,
  #   cache_prefix: "..."
  # }

  # Custom resource reference generator method
  # config.reference_generator = lambda do |resource, component|
  #   # Implement your custom method to generate resources references
  #   "1234-#{resource.id}"
  # end

  # Currency unit
  # config.currency_unit = "€"

  # The number of reports which an object can receive before hiding it
  # config.max_reports_before_hiding = 3

  # Custom HTML Header snippets
  #
  # The most common use is to integrate third-party services that require some
  # extra JavaScript or CSS. Also, you can use it to add extra meta tags to the
  # HTML. Note that this will only be rendered in public pages, not in the admin
  # section.
  #
  # Before enabling this you should ensure that any tracking that might be done
  # is in accordance with the rules and regulations that apply to your
  # environment and usage scenarios. This component also comes with the risk
  # that an organization's administrator injects malicious scripts to spy on or
  # take over user accounts.
  #
  config.enable_html_header_snippets = false

  # SMS gateway configuration
  #
  # If you want to verify your users by sending a verification code via
  # SMS you need to provide a SMS gateway service class.
  #
  # An example class would be something like:
  #
  # class MySMSGatewayService
  #   attr_reader :mobile_phone_number, :code
  #
  #   def initialize(mobile_phone_number, code)
  #     @mobile_phone_number = mobile_phone_number
  #     @code = code
  #   end
  #
  #   def deliver_code
  #     # Actual code to deliver the code
  #     true
  #   end
  # end
  #
  # config.sms_gateway_service = "MySMSGatewayService"

  # Timestamp service configuration
  #
  # Provide a class to generate a timestamp for a document. The instances of
  # this class are initialized with a hash containing the :document key with
  # the document to be timestamped as value. The istances respond to a
  # timestamp public method with the timestamp
  #
  # An example class would be something like:
  #
  # class MyTimestampService
  #   attr_accessor :document
  #
  #   def initialize(args = {})
  #     @document = args.fetch(:document)
  #   end
  #
  #   def timestamp
  #     # Code to generate timestamp
  #     "My timestamp"
  #   end
  # end
  #
  # config.timestamp_service = "MyTimestampService"

  # PDF signature service configuration
  #
  # Provide a class to process a pdf and return the document including a
  # digital signature. The instances of this class are initialized with a hash
  # containing the :pdf key with the pdf file content as value. The instances
  # respond to a signed_pdf method containing the pdf with the signature
  #
  # An example class would be something like:
  #
  # class MyPDFSignatureService
  #   attr_accessor :pdf
  #
  #   def initialize(args = {})
  #     @pdf = args.fetch(:pdf)
  #   end
  #
  #   def signed_pdf
  #     # Code to return the pdf signed
  #   end
  # end
  #
  # config.pdf_signature_service = "MyPDFSignatureService"

  # Etherpad configuration
  #
  # Only needed if you want to have Etherpad integration with Decidim. See
  # Decidim docs at docs/services/etherpad.md in order to set it up.
  #
  # config.etherpad = {
  #   server: Rails.application.secrets.etherpad[:server],
  #   api_key: Rails.application.secrets.etherpad[:api_key],
  #   api_version: Rails.application.secrets.etherpad[:api_version]
  # }
end

Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale
