# frozen_string_literal: true

module Turku
  # This class deals with uploading video section videos to the front page
  # content blocks.
  class VideoUploader < Decidim::ApplicationUploader
    def content_type_allowlist
      extension_allowlist.map { |ext| "video/#{ext}" }
    end

    def extension_allowlist
      %w(mp4 webm)
    end
  end
end
