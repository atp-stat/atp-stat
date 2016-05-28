class CreatePlayerStatuses < ActiveRecord::Migration
  def change
    create_table :player_statuses do |t|
      t.string :year
      t.string :player_name
      t.integer :stability
      t.integer :toughness
      t.integer :mentality
      t.timestamps null: false
    end
  end
end
