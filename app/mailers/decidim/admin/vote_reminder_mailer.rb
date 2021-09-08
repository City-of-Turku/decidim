# frozen_string_literal: true

module Decidim
  module Admin
    class VoteReminderMailer < Decidim::ApplicationMailer
      include Decidim::TranslationsHelper
      include Decidim::SanitizeHelper

      helper Decidim::TranslationsHelper

      helper_method :routes

      def vote_reminder(user, orders)
        with_user(user) do
          @organization = user.organization
          @user = user
          @orders = orders
          wording = orders.count == 1 ? "email_subject.one" : "email_subject.other"

          subject = I18n.t(
            wording,
            scope: "decidim.admin.vote_reminder_mailer.vote_reminder",
            order_count: orders.count
          )

          mail(to: user.email, subject: subject)
        end
      end

      private

      def routes
        @routes ||= Decidim::EngineRouter.main_proxy(@orders.first.component)
      end
    end
  end
end
