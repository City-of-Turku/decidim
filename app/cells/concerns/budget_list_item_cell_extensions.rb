# frozen_string_literal: true

# Customizes the budget list item cell
module BudgetListItemCellExtensions
  extend ActiveSupport::Concern

  include ActionView::Helpers::NumberHelper

  included do
    property :description, :total_budget
  end

  def budget_to_currency(budget)
    number_to_currency(budget, unit: Decidim.currency_unit, precision: 0).gsub(/ /, "&nbsp;")
  end

  def description
    translated_attribute(budget.description)
  end

  def can_vote?
    return false if voted?

    current_workflow.vote_allowed?(budget)
  end
end
