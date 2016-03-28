class PlayerController < ApplicationController
  def show
    year = 2016
    @player = Player.convert_name_from_url_name(params[:player_url_name])
    @activities = Activity.where("player_name = ?", @player)
    @activities_vstop10 = Activity
      .where("opponent_rank <= ?", 10)
      .where("player_name = ?", @player)
      .where("year = ?", year)
      .order("tournament_start_date")
      .order("id DESC")
    @activities_higher = Activity
      .where("player_rank > opponent_rank")
      .where("player_name = ?", @player)
      .where("year = ?", year)
      .order("tournament_start_date")
      .order("id DESC")
    @activities_lower = Activity
      .where("player_rank < opponent_rank")
      .where("win_loss = ?", "L")
      .where("player_name = ?", @player)
      .where("year = ?", year)
      .order("tournament_start_date")
      .order("id DESC")
  end
end
