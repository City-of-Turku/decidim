class CreateTurkuVotingReminders < ActiveRecord::Migration[5.2]
  def change
    create_table :turku_voting_reminders do |t|
      t.belongs_to :decidim_user, index: true, foreign_key: true
      t.belongs_to :decidim_component, foreign_key: true
      t.datetime :times, array: true, default: []
    end
  end
end
