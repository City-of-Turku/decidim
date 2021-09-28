# frozen_string_literal: true

class AddTurkuOidToIdentities < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_identities, :turku_oid, :string, default: nil
  end
end
