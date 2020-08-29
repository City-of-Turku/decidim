# frozen_string_literal: true

# Customizes the budget list item cell
module ProjectListItemCellExtensions
  extend ActiveSupport::Concern

  private

  def resource_description
    translated_attribute model.description
  end

  def resource_description_teaser
    truncate strip_tags(resource_description), length: 200
  end
end
