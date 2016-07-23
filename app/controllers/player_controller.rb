class PlayerController < ApplicationController
  def index
    @players = Player.all
    respond_to do |format|
      format.html
      format.json { render json: @players }
    end
  end

  def show
    @year = Date.today.year.to_s
    @year = params[:year].to_s if params[:year]
    @player = Player.convert_name_from_url_name(params[:id])
    @activities = Activity
      .where("player_name = ?", @player)
      .where("year = ?", @year)
    @activities_all_win_count = Activity
      .where("player_name = ?", @player)
      .where("year = ?", @year)
      .where("win_loss = ?", "W")
      .count
    @activities_all_lose_count = Activity
      .where("player_name = ?", @player)
      .where("year = ?", @year)
      .where("win_loss = ?", "L")
      .count
    @activities_vstop10 = Activity
      .where("opponent_rank <= ?", 10)
      .where("player_name = ?", @player)
      .where("year = ?", @year)
      .order("tournament_start_date")
      .order("id DESC")
    @activities_vstop10_win_count = Activity
      .where("opponent_rank <= ?", 10)
      .where("player_name = ?", @player)
      .where("year = ?", @year)
      .where("win_loss = ?", "W")
      .count
    @activities_vstop10_lose_count = Activity
      .where("opponent_rank <= ?", 10)
      .where("player_name = ?", @player)
      .where("year = ?", @year)
      .where("win_loss = ?", "L")
      .count
    @activities_higher = Activity
      .where("player_rank > opponent_rank")
      .where("player_name = ?", @player)
      .where("year = ?", @year)
      .order("tournament_start_date")
      .order("id DESC")
    @activities_higher_win_count = Activity
      .where("player_rank > opponent_rank")
      .where("player_name = ?", @player)
      .where("year = ?", @year)
      .where("win_loss = ?", "W")
      .count
    @activities_higher_lose_count = Activity
      .where("player_rank > opponent_rank")
      .where("player_name = ?", @player)
      .where("year = ?", @year)
      .where("win_loss = ?", "L")
      .count
    @activities_lower = Activity
      .where("player_rank < opponent_rank")
      .where("player_name = ?", @player)
      .where("year = ?", @year)
      .order("tournament_start_date")
      .order("id DESC")
    @activities_lower_win_count = Activity
      .where("player_rank < opponent_rank")
      .where("player_name = ?", @player)
      .where("year = ?", @year)
      .where("win_loss = ?", "W")
      .count
    @activities_lower_lose_count = Activity
      .where("player_rank < opponent_rank")
      .where("player_name = ?", @player)
      .where("year = ?", @year)
      .where("win_loss = ?", "L")
      .count

    respond_to do |format|
      format.html
      format.json { render json: @activities }
    end
  end
end
