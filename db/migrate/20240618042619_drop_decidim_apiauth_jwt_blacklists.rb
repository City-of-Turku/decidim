# frozen_string_literal: true

class DropDecidimApiauthJwtBlacklists < ActiveRecord::Migration[6.1]
  def change
    drop_table :decidim_apiauth_jwt_blacklists
  end
end
