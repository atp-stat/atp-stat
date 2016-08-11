class TopController < ApplicationController
  def index
    @players = Player.all
    @players_count = Player.all.count
    @activities_count = Activity.all.count
    @ranking_vs_top10  = PlayerStatus.ranking_vs_top10
    @ranking_vs_higher = PlayerStatus.ranking_vs_higher
    @ranking_vs_lower  = PlayerStatus.ranking_vs_lower
  end

  def about
  end
end
