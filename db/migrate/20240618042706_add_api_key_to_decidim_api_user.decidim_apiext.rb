# frozen_string_literal: true
# This migration comes from decidim_apiext (originally 20231201095250)

class AddApiKeyToDecidimApiUser < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_users, :api_key, :string
  end
end
