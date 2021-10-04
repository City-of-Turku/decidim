# frozen_string_literal: true

require "turku/mutation_extensions"
require "turku/query_extensions"

Decidim::Api::MutationType.include Turku::MutationExtensions
Decidim::Api::QueryType.include Turku::QueryExtensions
