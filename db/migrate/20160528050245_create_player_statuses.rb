class CreatePlayerStatuses < ActiveRecord::Migration
  def change
    create_table :player_statuses do |t|
      t.string :year
      t.string :player_name
      t.float :stability
      t.float :toughness
      t.float :mentality
      t.float :explosive
      t.float :momentum
      t.timestamps null: false
    end
    add_index :player_statuses, [:year, :player_name], unique: true, name: 'player_statuses_uniq_index'
  end
end
