# frozen_string_literal: true

module ApplicationHelper
  def logo_image_tag(version: nil)
    suffix = current_locale == "sv" ? "-sv" : ""
    suffix += "-#{version}" if version

    image_location = "media/images/logo#{suffix}.svg"
    image_pack_tag(
      image_location,
      alt: t("logo", scope: "decidim.accessibility", organization: current_organization.name)
    )
  end
end
