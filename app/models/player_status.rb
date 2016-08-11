class PlayerStatus < ActiveRecord::Base
  belongs_to :player, foreign_key: :player_name, primary_key: :name

  scope :default, ->(year, limit) {
    joins(:player)
    .where("year = ?", year)
    .limit(limit)
  }

  def self.ranking_vs_top10(year = Date.today.year.to_s, limit = 10)
    PlayerStatus.default(year, limit)
      .order("vs_top10_win DESC, vs_top10_loss ASC")
  end

  def self.ranking_vs_higher(year = Date.today.year.to_s, limit = 10)
    PlayerStatus.default(year, limit)
      .order("vs_higher_win DESC, vs_higher_loss ASC")
  end

  def self.ranking_vs_lower(year = Date.today.year.to_s, limit = 10)
    PlayerStatus.default(year, limit)
      .where("vs_lower_win != ?", 0)
      .order("vs_lower_loss ASC, vs_lower_win DESC")
  end
end
