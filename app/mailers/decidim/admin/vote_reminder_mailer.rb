# frozen_string_literal: true

module Decidim
  module Admin
    class VoteReminderMailer < Decidim::ApplicationMailer
      include Decidim::TranslationsHelper
      include Decidim::SanitizeHelper

      helper Decidim::TranslationsHelper

      helper_method :component_url, :budget_url

      def vote_reminder(user, order_ids)
        with_user(user) do
          @organization = user.organization
          @user = user
          @orders = Decidim::Budgets::Order.where(id: order_ids)
          wording = @orders.count == 1 ? "email_subject.one" : "email_subject.other"

          subject = I18n.t(
            wording,
            scope: "decidim.admin.vote_reminder_mailer.vote_reminder",
            order_count: @orders.count
          )

          mail(to: user.email, subject: subject)
        end
      end

      private

      def budget_url(order)
        path = routes.budget_path(order.budget)
        return path if URI.parse(path).host.present?

        "#{resolve_base_url}#{path}"
      end

      def component_url
        "#{resolve_base_url}#{routes.root_path}"
      end

      def resolve_base_url
        uri = URI.parse(routes.decidim.root_url(host: @organization.host))
        if uri.port.blank? || [80, 443].include?(uri.port)
          "#{uri.scheme}://#{uri.host}"
        else
          "#{uri.scheme}://#{uri.host}:#{uri.port}"
        end
      end

      def routes
        @routes ||= Decidim::EngineRouter.main_proxy(@orders.first.component)
      end
    end
  end
end
