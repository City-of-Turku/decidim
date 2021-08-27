class AddTurkuVotingReminderToOrder < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_budgets_orders, :turku_voting_reminder, foreign_key: true
  end
end
