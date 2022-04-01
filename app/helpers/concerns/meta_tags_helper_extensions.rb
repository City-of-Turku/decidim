# frozen_string_literal: true

module MetaTagsHelperExtensions
  extend ActiveSupport::Concern

  included do
    def add_decidim_meta_tags(tags)
      add_decidim_page_title(tags[:title])
      add_decidim_meta_description(tags[:description])
      add_decidim_meta_url(tags[:url])
      add_decidim_meta_twitter_handler(tags[:twitter_handler])
      add_decidim_meta_image_url(add_turku_base_url(tags[:image_url]))
    end

    def add_turku_base_url(path)
      return path if path.include?(turku_resolve_base_url)
      return path if path.blank?

      "#{turku_resolve_base_url}#{path}"
    end

    def turku_resolve_base_url
      return request.base_url if request&.base_url.present?

      uri = URI.parse(decidim.root_url(host: current_organization.host))
      "#{uri.scheme}://#{uri.host}"
    end
  end
end
