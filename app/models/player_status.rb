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

  def self.calculate(name, year)
    {
      :year => year,
      :player_name => name,
      :explosive => Activity.calculate_status_explosive(name, year),
      :stability => Activity.calculate_status_stability(name, year),
      :mentality => Activity.calculate_status_mentality(name, year),
      :momentum  => Activity.calculate_status_momentum(name, year),
      :toughness => Activity.calculate_status_toughness(name, year),
      :vs_top10_win  => Activity.count_vs_top10(name, year, 'W'),
      :vs_top10_loss => Activity.count_vs_top10(name, year, 'L'),
      :vs_higher_win  => Activity.count_vs_higher(name, year, 'W'),
      :vs_higher_loss => Activity.count_vs_higher(name, year, 'L'),
      :vs_lower_win  => Activity.count_vs_lower(name, year, 'W'),
      :vs_lower_loss => Activity.count_vs_lower(name, year, 'L')
    }
  end

  def self.create_or_update(data)
    record = PlayerStatus.where(
      :year => data[:year],
      :player_name => data[:player_name]
    )
    if record.exists?
      record.update_all(data)
      puts "Record update(#{data[:player_name]},#{data[:year]})"
    else
      PlayerStatus.create(data)
      puts "Record create(#{data[:player_name]},#{data[:year]})"
    end
  end
end
