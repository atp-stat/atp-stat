class PlayerStatus < ActiveRecord::Base
  def self.ranking_vs_top10(year = Date.today.year.to_s, limit = 10)
    PlayerStatus
      .where("year = ?", year)
      .order("vs_top10_win DESC, vs_top10_loss ASC")
      .limit(limit)
  end
end
