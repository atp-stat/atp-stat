class CreateActivityJobs < ActiveRecord::Migration
  def change
    create_table :activity_jobs do |t|
      t.string :player_name
      t.string :player_id
      t.string :year
      t.timestamps null: false
    end
  end
end
