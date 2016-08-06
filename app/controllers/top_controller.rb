class TopController < ApplicationController
  def index
    @players = Player.all
    @ranking_vs_top10 = PlayerStatus.ranking_vs_top10
  end
end
