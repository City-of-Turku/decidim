# frozen_string_literal: true

require_relative "boot"

require "decidim/rails"
# Add the frameworks used by your app that are not loaded by Decidim.
require "action_cable/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DecidimTurku
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.time_zone = "Europe/Helsinki"

    # Configure an application wide address suffix to pass to the geocoder.
    # This is to make sure that the addresses are not incorrectly mapped outside
    # of the wanted area.
    config.address_suffix = "Turku, Finland"

    # Sending address for mails
    config.mailer_sender = "osallisuus@turku.fi"

    config.search_indexing = true

    # Add the override translations to the load path
    config.i18n.load_path += Dir[
      Rails.root.join("config/locales/overrides/*.yml").to_s
    ]

    # Remind users who haven't checked out their votes
    config.reminder_times = [2.hours, 1.week, 2.weeks]

    initializer "turku.admin_routes", before: :add_routing_paths do
      Decidim::Budgets::AdminEngine.routes.append do
        resource :vote_reminder, only: [:new, :create]
      end
    end

    initializer "turku.api_extensions" do
      require "turku/api/query_extensions"
      require "turku/api/mutation_extensions"
      require "turku/api/author_interface_extensions"
      require "turku/api/user_type_extensions"

      Decidim::Api::QueryType.include Turku::Api::QueryExtensions
      Decidim::Api::MutationType.include Turku::Api::MutationExtensions
      Decidim::Core::AuthorInterface.include Turku::Api::AuthorInterfaceExtensions
      Decidim::Core::UserType.include Turku::Api::UserTypeExtensions
    end

    initializer "turku.budget_workflows" do
      Decidim::Budgets.workflows[:asukasbudjetti] = Turku::Budgets::Workflows::Asukasbudjetti
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Add the to_prepare hook AFTER the decidim.action_controller initializer
    # because otherwise a necessary helper would be missing from some of the
    # controllers.
    initializer "customizations", after: "decidim.action_controller" do
      # See:
      # https://guides.rubyonrails.org/configuring.html#initialization-events
      #
      # Run before every request in development.
      config.to_prepare do
        # Cell extensions
        ::Decidim::Budgets::BudgetListItemCell.include(
          BudgetListItemCellExtensions
        )
        ::Decidim::Budgets::BudgetInformationModalCell.include(
          BudgetInformationModalExtensions
        )
        ::Decidim::Budgets::ProjectListItemCell.include(
          ProjectListItemCellExtensions
        )
        ::Decidim::Budgets::BudgetsListCell.include(
          BudgetsListCellExtensions
        )

        # Model extensions
        ::Decidim::User.include(UserExtensions)
        ::Decidim::ActionLog.include(ActionLogExtensions)

        # Controller extensions
        ::Decidim::Proposals::ProposalsController.include(ProposalsExtensions)
        ::Decidim::Budgets::LineItemsController.include(LineItemsExtensions)
        ::Decidim::PagesController.include(PagesExtensions)

        # Command extensions
        ::Decidim::CreateOmniauthRegistration.include(CreateOmniauthRegistrationExtensions)
        ::Decidim::Budgets::Checkout.include(CheckoutExtensions)

        # Authorizer extensions
        ::Decidim::ActionAuthorizer::AuthorizationStatusCollection.include(
          AuthorizationStatusCollectionExtensions
        )

        # Helper extensions
        ::Decidim::ActionAuthorizationHelper.include(
          ActionAuthorizationHelperExtensions
        )
      end
    end
  end
end
