namespace :atp_stat do
  namespace :ranking do
    desc "Get player ranking and import them to db."
    task :get, ['range'] => :environment do |task, args|
      players = AtpScraper::Get.singles_ranking(args[:range])
      players.each do |player|
        begin
          Player.create(
            name: player[:player_name],
            url_name: player[:player_url_name],
            url_id: player[:player_id]
          )
          ActivityJob.create(
            player_name: player[:player_name],
            player_id: player[:player_id],
            year: "all"
          )
          puts "[Create] Record create(#{player[:player_name]})"
        rescue ActiveRecord::RecordNotUnique => e
          puts "[Skip] Record Duplicate(#{player[:player_name]})"
          next
        end
      end
    end
  end
  namespace :activity do
    desc "Get player activity and import them to db."
    task :get, ['player_id', 'year'] => :environment do |task, args|
      activities = AtpScraper::Get.player_activity(
        args[:player_id],
        args[:year]
      )
      activities.each do |activity|
        begin
          Activity.create(activity)
          puts "[Create] Record create (#{activity})"
        rescue ActiveRecord::RecordNotUnique => e
          puts "[Skip] Record duplicate (#{activity})"
          next
        end
      end
    end

    desc "Weekly batch. Register jobs to get latest acitivity for all players."
    task :register_job_latest => :environment do |task, args|
      players = Player.all
      players.each do |player|
        ActivityJob.create(
          player_name: player.name,
          player_id: player.url_id,
          year: Date.today.year.to_s
        )
        puts "[Job Created] #{player.name}"
      end
    end

    desc "Exec job to get activity."
    task :exec_job => :environment do |task, args|
      job = ActivityJob.where(working: 0).where(finished: 0).first
      job.update(working: 1, finished: 1)
      begin
        Rake::Task["atp_stat:activity:get"].invoke(job.player_id, job.year)
      rescue => e
        job.update(working: 0, finished: 0)
      end
    end

    desc "Calculate player status"
    task :calculate_status, ['player_name', 'year'] => :environment do |task, args|
      players = Activity.select("player_name").uniq!
      players.each do |player|
        # Explosive_value
        name = player.player_name
        matches_higher_win = Activity
          .where("player_name = ?",name)
          .where("year = ?",args[:year])
          .where("player_rank !=0 ")
          .where("opponent_rank !=0 ")
          .where("player_rank > opponent_rank")
          .where("win_loss = ?", "W")
        matches_higher_all_count = Activity
          .where("player_name = ?",name)
          .where("year = ?",args[:year])
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
        puts "PlayerName = " + name.to_s
        puts "Explosive_Value = " + explosive_value.to_s

        #Stability_value
        matches_lower_lose = Activity
          .where("player_name = ?",name)
          .where("year = ?",args[:year])
          .where("player_rank !=0 ")
          .where("opponent_rank !=0 ")
          .where("player_rank < opponent_rank")
          .where("win_loss = ?", "L")
        matches_lower_all_count = Activity
          .where("player_name = ?",name)
          .where("year = ?",args[:year])
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

      #Mentality_value
      matches_win = Activity
        .where("player_name = ?",name)
        .where("year = ?",args[:year])
        .where("win_loss = ?", "W")
      matches_win_count = Activity
        .where("player_name = ?",name)
        .where("year = ?",args[:year])
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

      #Momentum_value

      #Toughness_value

      end
    end

  end
end
