class PlayerController < ApplicationController
  def show
    @player_name = params[:player_id]
  end
end
