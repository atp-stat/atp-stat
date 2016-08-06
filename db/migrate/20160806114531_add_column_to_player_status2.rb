class AddColumnToPlayerStatus2 < ActiveRecord::Migration
  def change
    add_column :player_statuses, :vs_higher_win, :integer
    add_column :player_statuses, :vs_higher_loss, :integer
    add_column :player_statuses, :vs_lower_win, :integer
    add_column :player_statuses, :vs_lower_loss, :integer
  end
end
