class TopController < ApplicationController
  def index
    @players = Player.all
    @players_count = Player.all.count
    @activities_count = Activity.all.count
    @ranking_vs_top10  = PlayerStatus.ranking_vs_top10
    @ranking_vs_higher = PlayerStatus.ranking_vs_higher
    @ranking_vs_lower  = PlayerStatus.ranking_vs_lower
    @ranking = Ranking.joins(:player).order("ranking asc").limit(30)
  end

  def about
  end
end
