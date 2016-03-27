class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.string :url_name
      t.string :url_id
      t.timestamps null: false
    end
    add_index :players, :url_id, unique: true, name: 'players_uniq_index'
  end
end
