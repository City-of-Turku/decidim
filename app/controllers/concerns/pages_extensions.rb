# frozen_string_literal: true

module PagesExtensions
  extend ActiveSupport::Concern

  included do
    skip_before_action :store_current_location, if: -> { params.has_key?(:id) && params[:id] == "terms-and-conditions" }
  end
end
