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
    matches_higher = Activity
      .where("player_name = ?",player_name)
      .where("year = ?",year)
      .where("player_rank !=0 ")
      .where("opponent_rank !=0 ")
      .where("player_rank > opponent_rank")
    matches_higher_win = matches_higher
      .where("win_loss = ?", "W")
    matches_higher_all_count = matches_higher
      .count
    if matches_higher_all_count != 0
      explosive_points = 0
      matches_higher_win.each do |match_higher_win|
        rank_remainder = match_higher_win.player_rank.to_i - match_higher_win.opponent_rank.to_i
        explosive_point = (rank_remainder.to_f / match_higher_win.player_rank.to_f) ** (1.0/2.0)
        explosive_points += explosive_point
      end
      explosive_value = explosive_points * (matches_higher_win.count / matches_higher_all_count) ** (1/2) * 10.0
    else
      explosive_value = 0
    end
  end

  #Stability_value
  def self.calculate_status_stability(player_name,year)
    matches_lower = Activity
      .where("player_name = ?",player_name)
      .where("year = ?",year)
      .where("player_rank !=0 ")
      .where("opponent_rank !=0 ")
      .where("player_rank < opponent_rank")
    matches_lower_win = matches_lower
      .where("win_loss = ?", "W")
    matches_lower_lose = matches_lower
      .where("win_loss = ?", "L")
    matches_lower_all_count = matches_lower
      .count
    matches_lower_win_count = matches_lower_win
      .count
    matches_lower_lose_count = matches_lower_lose
      .count
    if matches_lower_all_count != 0
      stability_points = 0
      matches_lower_win.each do |match_lower_win|
        rank_remainder = match_lower_win.opponent_rank.to_i - match_lower_win.player_rank.to_i
        stability_point = 1.0 + (1.0 / rank_remainder.to_f)
        stability_points += stability_point
      end
      stability_value = stability_points / matches_lower_all_count.to_f * 100.0
    else
      stability_value = 0
    end
  end

  #Mentality_value
  def self.calculate_status_mentality(player_name,year)
      match_results = Activity
        .where("player_name = ?",player_name)
        .where("year = ?",year)
      match_results_count = match_results
        .count
      match_results_win = match_results
        .where("win_loss = ?", "W")
      match_results_win_count = match_results_win
        .count
      if match_results_win_count != 0
        mentality_points = 0
        match_results_win.each do |match_win|
          case match_win.tournament_category
          when "grandslam" then
            mentality_point = 1.2
          when "finals-pos" then
            mentality_point = 1.2
          when "1000s" then
            mentality_point = 1.0
          when "500" then
            mentality_point = 0.8
          when "atpwt" then
            mentality_point = 0.6
          when "250" then
            mentality_point = 0.5
          when "challenger" then
            mentality_point = 0.4
          when "itf" then
            mentality_point = 0.4
          else
            mentality_point = 0.4
          end
          mentality_points += mentality_point
        end
        mentality_value = (mentality_points.to_f / match_results_win_count.to_f) * 100
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
      matches_current_year_count = matches_current_year
        .count
      ranking_current_year_total = 0
      matches_current_year.each do |match_current_year|
        ranking_current_year = match_current_year.player_rank
        ranking_current_year_total += ranking_current_year
      end
      if matches_current_year_count != 0
        ranking_current_year_average = ranking_current_year_total.to_f/matches_current_year_count.to_f
      else
        ranking_current_year_average = 0
      end

      year = year.to_i - 1
      year = year.to_s

      matches_last_year = Activity
        .where("player_name = ?",player_name)
        .where("player_rank != 0")
        .where("year = ?",year)
      matches_last_year_count = matches_last_year
        .count
      ranking_last_year_total = 0
      matches_last_year.each do |match_last_year|
        ranking_last_year = match_last_year.player_rank
        ranking_last_year_total += ranking_last_year
      end
      if matches_last_year_count != 0
        ranking_last_year_average = ranking_last_year_total.to_f/matches_last_year_count.to_f
      else
        ranking_last_year_average = 0
      end
      if ranking_last_year_average != 0 && ranking_last_year_average != 1.0
        momentum_value = 50.0 + (ranking_last_year_average - ranking_current_year_average) / Math.log(ranking_last_year_average)
        momentum_value = 0.0 if momentum_value < 0.0
        return momentum_value
      else
        momentum_value = 50.0
      end
  end

  #toughness_value
  def self.calculate_status_toughness(player_name,year)
    match_results = Activity
      .where("player_name = ?",player_name)
      .where("year = ?",year)
    fullset_count = 0
    toughness_point = 0.0
    match_results_win = match_results
          .where("win_loss = ?", "W")
    match_results_lose = match_results
          .where("win_loss = ?", "L")
    match_results_win.each do |match_result|
      score = match_result.score
      splitscore = score.split(/\s/)
      if splitscore.select{|x| x[0] == "("} != [] || splitscore.count == 0
      else
        case splitscore.count
        when 5
          fullset_count = fullset_count + 100
          toughness_point = toughness_point + 130
        when 4
        when 3
          if splitscore.select{|x| x[0] < x[1] } != []
            fullset_count = fullset_count + 100
            toughness_point = toughness_point + 110
          else
          end
        else # 2, 1セット
        end
      end
    end
    match_results_lose.each do |match_result|
      score = match_result.score
      splitscore = score.split(/\s/)
      if splitscore.select{|x| x[0] == "("} != [] || splitscore.count == 0
      else
        case splitscore.count
        when 5
          fullset_count = fullset_count + 100
        when 4
        when 3
          if splitscore.select{|x| x[0] < x[1] } != []
            fullset_count = fullset_count + 100
          else
          end
        else # 2, 1セット
        end
      end
    end
    if fullset_count != 0
      toughness_value = toughness_point / fullset_count * 100
    else
      toughness_value = 0.0
    end
  end
end
