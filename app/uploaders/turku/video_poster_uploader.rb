# frozen_string_literal: true

module Turku
  # This class deals with uploading video section poster images the front page
  # content blocks.
  class VideoPosterUploader < Decidim::ImageUploader
    set_variants do
      {
        poster: { resize_to_fill: [1920, 1080] }
      }
    end

    def content_type_allowlist
      extension_allowlist.excluding("jpg").map { |ext| "image/#{ext}" }
    end

    def extension_allowlist
      %w(jpg jpeg png webp)
    end
  end
end
