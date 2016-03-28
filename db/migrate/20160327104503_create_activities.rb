class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :year
      t.string :player_name
      t.integer :player_rank
      t.string :opponent_name
      t.integer :opponent_rank
      t.string :round
      t.string :score
      t.string :win_loss
      t.string :tournament_name
      t.string :tournament_category
      t.string :tournament_location
      t.date :tournament_start_date
      t.date :tournament_end_date
      t.string :tournament_surface
      t.string :tournament_surface_inout
      t.timestamps null: false
    end
    add_index :activities, [:year, :player_name, :opponent_name, :round, :tournament_name], unique: true, name: 'activities_uniq_index'
  end
end
