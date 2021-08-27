class CreateTurkuVotingReminders < ActiveRecord::Migration[5.2]
  def change
    create_table :turku_voting_reminders do |t|
      t.belongs_to :decidim_user, index: true, foreign_key: true
    end
  end
end
