# frozen_string_literal: true

require "turku/mutation_extensions"

Decidim::Api::MutationType.include Turku::MutationExtensions
