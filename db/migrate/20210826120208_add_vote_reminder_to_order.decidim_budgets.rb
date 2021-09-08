class AddVoteReminderToOrder < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_budgets_orders, :decidim_vote_reminder, foreign_key: true
  end
end
