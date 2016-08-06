class PlayerStatus < ActiveRecord::Base
  def self.ranking_vs_top10(year = Date.today.year.to_s, limit = 10)
    PlayerStatus
      .where("year = ?", year)
      .order("vs_top10_win DESC, vs_top10_loss ASC")
      .limit(limit)
  end

  def self.ranking_vs_higher(year = Date.today.year.to_s, limit = 10)
    PlayerStatus
      .where("year = ?", year)
      .order("vs_higher_win DESC, vs_higher_loss ASC")
      .limit(limit)
  end

  def self.ranking_vs_lower(year = Date.today.year.to_s, limit = 10)
    PlayerStatus
      .where("year = ?", year)
      .order("vs_lower_loss ASC, vs_lower_win DESC")
      .limit(limit)
  end
end
