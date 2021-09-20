# frozen_string_literal: true
# This migration comes from decidim_tunnistamo (originally 20210909163501)

class AddTunnistamoConfirmedEmailToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :tunnistamo_email_sent_to, :string, default: nil
    add_column :decidim_users, :tunnistamo_email_code, :string, default: nil
    add_column :decidim_users, :tunnistamo_email_code_sent_at, :datetime, default: nil
    add_column :decidim_users, :tunnistamo_failed_confirmation_attempts, :integer, default: 0
  end
end
