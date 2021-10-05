# frozen_string_literal: true

module Turku
  module Api
    module AuthorInterfaceExtensions
      def self.included(type)
        type.field :activity_types, [Turku::Api::ActivityType, { null: true }], "User's activities", null: false
      end
    end
  end
end
