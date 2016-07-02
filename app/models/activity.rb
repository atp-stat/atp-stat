class Activity < ActiveRecord::Base
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
        puts "PlayerName = " + player_name.to_s
        puts "Explosive_Value = " + explosive_value.to_s
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
      puts "Stability_Value = " + stability_value.to_s
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
          if point_category == "grandslam" then
            mentality_point = 10
          elsif point_category == "finals-pos" then
            mentality_point = 10
          elsif point_category == "1000s" then
            mentality_point = 5
          elsif point_category == "500" then
            mentality_point = 2
          elsif point_category == "250" then
            mentality_point = 1
          elsif point_category == "atpwt" then
            mentality_point = 2
          elsif point_category == "challenger" then
            mentality_point = 0
          elsif point_category == "itf" then
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
      puts "Mentality_Value = " + mentality_value.to_s
  end
end
