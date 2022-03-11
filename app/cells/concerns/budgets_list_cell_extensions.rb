# frozen_string_literal: true

# Customizes the budget list item cell
module BudgetsListCellExtensions
  extend ActiveSupport::Concern

  included do
    def active_budgets
      @active_budgets ||= budgets.select { |budget| current_workflow.vote_allowed?(budget) }
    end

    def completed_budgets
      @completed_budgets ||= current_workflow.voted
    end

    def locked_budgets
      @locked_budgets ||= budgets - (active_budgets + completed_budgets)
    end
  end

  def turku_voting?
    current_workflow.is_a?(Turku::Budgets::Workflows::Asukasbudjetti)
  end
end
