class AddColumnToPlayerStatus < ActiveRecord::Migration
  def change
    add_column :player_statuses, :vs_top10_win, :integer
    add_column :player_statuses, :vs_top10_loss, :integer
  end
end
