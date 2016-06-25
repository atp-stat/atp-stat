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
        name = player.player_name
        matches_higher = Activity
          .where("player_name = ?",name)
          .where("year = ?",args[:year])
          .where("player_rank !=0 ")
          .where("opponent_rank !=0 ")
          .where("player_rank > opponent_rank")
        matches_higher_count = Activity
          .where("player_name = ?",name)
          .where("year = ?",args[:year])
          .where("player_rank !=0 ")
          .where("opponent_rank !=0 ")
          .where("player_rank > opponent_rank")
          .count
        if matches_higher_count != 0
          explosive_points = 0
          matches_higher.each do |match_higher|
            ranking_difference = match_higher.player_rank.to_i - match_higher.opponent_rank.to_i
            explosive_point = 1 / match_higher.opponent_rank.to_f * (ranking_difference.to_f / match_higher.player_rank.to_f) ** 2
            explosive_points += explosive_point
          end
          explosive_value = explosive_points / matches_higher_count
        else
          explosive_value = 0
        end
        puts "PlayerName = " + name.to_s
        puts "Explosive_Value = " + explosive_value.to_s
      end
    end

  end
end
