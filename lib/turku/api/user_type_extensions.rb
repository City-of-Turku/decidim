# frozen_string_literal: true

module Turku
  module Api
    module UserTypeExtensions
      def activity_types
        visibility = context[:current_user].admin? ? %w(private-only public-only all) : %w(public-only all)

        ::Decidim::ActionLog.where(
          user: object,
          visibility: visibility,
          organization: context[:current_organization]
        )
      end
    end
  end
end
