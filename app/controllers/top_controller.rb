class TopController < ApplicationController
  def index
    @players = Player.all
    @ranking_vs_top10  = PlayerStatus.ranking_vs_top10
    @ranking_vs_higher = PlayerStatus.ranking_vs_higher
    @ranking_vs_lower  = PlayerStatus.ranking_vs_lower
  end
end
