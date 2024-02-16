# frozen_string_literal: true

module Turku
  module ContentBlocks
    class VideoCell < Decidim::ViewModel
      def show
        return unless has_video?

        render
      end

      private

      def title
        translated_attribute(model.settings.title)
      end

      def has_title?
        title.strip.present?
      end

      def description
        translated_attribute(model.settings.description)
      end

      def has_description?
        strip_tags(description).strip.present?
      end

      def poster_image
        return unless has_poster_image?

        model.images_container.attached_uploader(:poster).path(variant: :poster)
      end

      def video
        return unless has_video?

        model.images_container.attached_uploader(:video).path
      end

      def has_video?
        return false if model.images_container.video.blank?
        return false unless model.images_container.video.attached?

        true
      end

      def has_poster_image?
        return false if model.images_container.poster.blank?
        return false unless model.images_container.poster.attached?

        true
      end
    end
  end
end
