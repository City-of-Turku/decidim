# frozen_string_literal: true

class PlaceholderController < Decidim::ApplicationController
  layout "layouts/placeholder/application"

  def index; end

  private

  def allow_unauthorized_path?
    true
  end
end
