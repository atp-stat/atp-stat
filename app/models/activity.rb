class Activity < ActiveRecord::Base
  belongs_to :player, foreign_key: :player_name, primary_key: :player_name

  scope :default_all, ->(name, year) {
    where("player_name = ?", name)
    .where("year = ?", year)
    .order("tournament_start_date")
    .order("id desc")
  }

  def self.count_vs_top10(player_name, year, win_loss)
    Activity.where("player_name = ?", player_name)
      .where("year = ?", year)
      .where("opponent_rank < 10")
      .where("win_loss = ?", win_loss)
      .count
  end

  def self.count_vs_higher(player_name, year, win_loss)
    Activity.where("player_name = ?", player_name)
      .where("year = ?", year)
      .where("player_rank > opponent_rank")
      .where("win_loss = ?", win_loss)
      .count
  end

  def self.count_vs_lower(player_name, year, win_loss)
    Activity.where("player_name = ?", player_name)
      .where("year = ?", year)
      .where("player_rank < opponent_rank")
      .where("win_loss = ?", win_loss)
      .count
  end

  # Explosive_value
  def self.calculate_status_explosive(player_name,year)
      matches_higher_win = Activity
        .where("player_name = ?",player_name)
        .where("year = ?",year)
        .where("player_rank !=0 ")
        .where("opponent_rank !=0 ")
        .where("player_rank > opponent_rank")
        .where("win_loss = ?", "W")
      matches_higher_all_count = Activity
        .where("player_name = ?",player_name)
        .where("year = ?",year)
        .where("player_rank !=0 ")
        .where("opponent_rank !=0 ")
        .where("player_rank > opponent_rank")
        .count
      if matches_higher_all_count != 0
        explosive_points = 0
        matches_higher_win.each do |match_higher_win|
          ranking_difference = match_higher_win.player_rank.to_i - match_higher_win.opponent_rank.to_i
          explosive_point = 1 / match_higher_win.opponent_rank.to_f * (ranking_difference.to_f / match_higher_win.player_rank.to_f) ** 2
          explosive_points += explosive_point
        end
        explosive_value = explosive_points / matches_higher_all_count
      else
        explosive_value = 0
      end
  end

  #Stability_value
  def self.calculate_status_stability(player_name,year)
      matches_lower_lose = Activity
        .where("player_name = ?",player_name)
        .where("year = ?",year)
        .where("player_rank !=0 ")
        .where("opponent_rank !=0 ")
        .where("player_rank < opponent_rank")
        .where("win_loss = ?", "L")
      matches_lower_all_count = Activity
        .where("player_name = ?",player_name)
        .where("year = ?",year)
        .where("player_rank !=0 ")
        .where("opponent_rank !=0 ")
        .where("player_rank < opponent_rank")
        .count
      if matches_lower_all_count != 0
        stability_points = 0
        matches_lower_lose.each do |match_lower_lose|
          ranking_difference = match_lower_lose.opponent_rank.to_i - match_lower_lose.player_rank.to_i
          stability_point = ((ranking_difference.to_f / match_lower_lose.player_rank.to_f) ** 2) * (match_lower_lose.opponent_rank.to_f ** 2 )
          stability_points += stability_point
        end
        if stability_points != 0
          stability_value =  matches_lower_all_count / stability_points
        else  # the case the player never losed to lower-ranking players
          stability_value = 1.0
        end
      else
        stability_value = 0
      end
  end

  #Mentality_value
  def self.calculate_status_mentality(player_name,year)
      matches_win = Activity
        .where("player_name = ?",player_name)
        .where("year = ?",year)
        .where("win_loss = ?", "W")
      matches_win_count = Activity
        .where("player_name = ?",player_name)
        .where("year = ?",year)
        .where("win_loss = ?", "W")
        .count
      if matches_win_count != 0
        mentality_points = 0
        matches_win.each do |match_win|
          point_category = match_win.tournament_category
          case point_category
          when "grandslam" then
            mentality_point = 10
          when "finals-pos" then
            mentality_point = 10
          when "1000s" then
            mentality_point = 5
          when "500" then
            mentality_point = 2
          when "250" then
            mentality_point = 1
          when "atpwt" then
            mentality_point = 2
          when "challenger" then
            mentality_point = 0
          when "itf" then
            mentality_point = 0
          else
            mentality_point = 0
          end
          mentality_points += mentality_point
        end
        mentality_value = mentality_points.to_f / matches_win_count.to_f
      else
        mentality_value = 0
      end
  end

  #Momentum_value
  def self.calculate_status_momentum(player_name,year)
      matches_current_year = Activity
        .where("player_name = ?",player_name)
        .where("player_rank != 0")
        .where("year = ?",year)
      matches_current_year_count = Activity
        .where("player_name = ?",player_name)
        .where("player_rank != 0")
        .where("year = ?",year)
        .count
      ranking_current_year_total = 0
      matches_current_year.each do |match_current_year|
        ranking_current_year = match_current_year.player_rank
        ranking_current_year_total += ranking_current_year
      end
      ranking_current_year_average = ranking_current_year_total.to_f/matches_current_year_count.to_f

      year = year.to_i - 1
      year = year.to_s

      matches_last_year = Activity
        .where("player_name = ?",player_name)
        .where("player_rank != 0")
        .where("year = ?",year)
      matches_last_year_count = Activity
        .where("player_name = ?",player_name)
        .where("player_rank != 0")
        .where("year = ?",year)
        .count
      ranking_last_year_total = 0
      matches_last_year.each do |match_last_year|
        ranking_last_year = match_last_year.player_rank
        ranking_last_year_total += ranking_last_year
      end
      ranking_last_year_average = ranking_last_year_total.to_f/matches_last_year_count.to_f

      year = year.to_i - 1
      year = year.to_s

      matches_2yearsago_year = Activity
        .where("player_name = ?",player_name)
        .where("player_rank != 0")
        .where("year = ?",year)
      matches_2yearsago_year_count = Activity
        .where("player_name = ?",player_name)
        .where("player_rank != 0")
        .where("year = ?",year)
        .count
      ranking_2yearsago_year_total = 0
      matches_2yearsago_year.each do |match_2yearsago_year|
        ranking_2yearsago_year = match_2yearsago_year.player_rank
        ranking_2yearsago_year_total += ranking_2yearsago_year
      end
      ranking_2yearsago_year_average = ranking_2yearsago_year_total.to_f/matches_2yearsago_year_count.to_f
      momentum_value = - ((ranking_current_year_average - ranking_last_year_average) - (ranking_last_year_average - ranking_2yearsago_year_average))
  end

  #toughness_value
  def self.calculate_status_toughness(player_name,year)
    return 0
  end
end
