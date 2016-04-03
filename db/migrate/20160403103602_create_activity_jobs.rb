class CreateActivityJobs < ActiveRecord::Migration
  def change
    create_table :activity_jobs do |t|
      t.string :player_name, null: false
      t.string :player_id, null: false
      t.string :year, null: false
      t.integer :working, default: 0
      t.integer :finished, default: 0
      t.timestamps null: false
    end
  end
end
