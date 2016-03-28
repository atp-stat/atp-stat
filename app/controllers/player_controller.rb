class PlayerController < ApplicationController
  def show
    @player = Player.convert_name_from_url_name(params[:player_url_name])
    @activities = Activity.where("player_name = ?", @player)
  end
end
