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
  end
end
