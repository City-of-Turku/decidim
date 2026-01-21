# frozen_string_literal: true

# Removes the necessity of the cost and cost-related attributes from the answer
# form to make admins' jobs easier. Also note that some of the fields may be
# empty when the proposal answers are pushed from the backoffice system.
module ProposalAnswerFormExtensions
  extend ActiveSupport::Concern

  included do
    [:cost, :cost_report, :execution_period].each do |field|
      _validators.reject! { |key, _| key == field }
      _validate_callbacks.each do |callback|
        _validate_callbacks.delete(callback) if callback.raw_filter.attributes == [field]
      end
    end
  end
end
