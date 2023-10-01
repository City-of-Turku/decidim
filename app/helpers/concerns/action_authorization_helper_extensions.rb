# frozen_string_literal: true

# Redirect to Tunnistamo instead of sing_in page / modal
module ActionAuthorizationHelperExtensions
  extend ActiveSupport::Concern

  included do
    # rubocop:disable Metrics/PerceivedComplexity
    def authorized_to(tag, action, arguments, block)
      if block
        body = block
        url = arguments[0]
        html_options = arguments[1]
      else
        body = arguments[0]
        url = arguments[1]
        html_options = arguments[2]
      end

      html_options ||= {}
      resource = html_options.delete(:resource)

      if !current_user
        html_options = clean_authorized_to_data_open(html_options)

        html_options[:method] ||= :post
        html_options.delete(:remote)
        url = ::Decidim::Core::Engine.routes.url_helpers.user_tunnistamo_omniauth_authorize_path
      elsif action && !action_authorized_to(action, resource: resource).ok?
        html_options = clean_authorized_to_data_open(html_options)

        html_options["data-open"] = "authorizationModal"
        html_options["data-open-url"] = modal_path(action, resource)
        url = "#"
      end

      if controller.respond_to?(:allowed_publicly_to?) && !controller.allowed_publicly_to?(action)
        html_options = clean_authorized_to_data_open(html_options)
        html_options[:id] ||= generate_authorized_action_id(tag, action, url) unless html_options.has_key?("id")
        html_options["data-privacy"] = { open: html_options["data-open"], openUrl: html_options["data-open-url"] }.compact.to_json
        html_options["data-open"] = "publishAccountModal"
        html_options.delete("data-open-url")
        url = "#"
      end

      html_options["onclick"] = "event.preventDefault();" if url == ""

      if block
        send("#{tag}_to", url, html_options, &body)
      else
        send("#{tag}_to", body, url, html_options)
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
