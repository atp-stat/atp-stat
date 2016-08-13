class CreateRankings < ActiveRecord::Migration
  def change
    create_table :rankings do |t|
      t.integer :ranking
      t.string :name
      t.integer :points
      t.date :date
      t.timestamps null: false
    end
    add_index :rankings, [:ranking, :name, :date], unique: true, name: 'rankings_uniq_index'
  end
end
