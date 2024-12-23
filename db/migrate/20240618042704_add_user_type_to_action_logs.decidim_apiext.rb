# frozen_string_literal: true
# This migration comes from decidim_apiext (originally 20231121156079)

class AddUserTypeToActionLogs < ActiveRecord::Migration[6.1]
  class User < ApplicationRecord
    self.table_name = :decidim_users
    self.inheritance_column = nil # disable the default inheritance

    default_scope { where(type: "Decidim::User") }
  end

  class ActionLog < ApplicationRecord
    self.table_name = :decidim_action_logs
  end

  def change
    add_column :decidim_action_logs, :user_type, :string

    ActionLog.find_each do |log|
      user = User.find_by(id: log.decidim_user_id) if log.decidim_user_id.present?
      log.update!(
        user_type: user.is_a?(User) ? user.type : "Decidim::Apiext::ApiUser",
        decidim_user_id: log.decidim_user_id
      )
    end
    rename_column :decidim_action_logs, :decidim_user_id, :user_id
    add_index :decidim_action_logs,
              [:user_id, :user_type],
              name: "index_decidim_action_log_on_users"
    change_column_null :decidim_action_logs, :user_id, false
    change_column_null :decidim_action_logs, :user_type, false
  end
end
