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
    
    desc "Update current top ranking."
    task :update => :environment do |task, args|
      Ranking.delete_all
      AtpScraper::Get.singles_ranking.each do |player|
        Ranking.create(
          ranking: player[:ranking],
          name: player[:player_name],
          points: player[:points],
          date: Date.today
        )
        puts "[Create] Record create(#{player[:player_name]})"
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
      data = PlayerStatus.calculate(args[:player_name], args[:year])
      PlayerStatus.create_or_update(data)
    end

    desc "Calculate player status for all players"
    task :calculate_status_all_players, ['year'] => :environment do |task, args|
      year = args[:year] || Date.today.year.to_s
      Player.select("name").each do |player|
        data = PlayerStatus.calculate(player.name, year)
        PlayerStatus.create_or_update(data)
      end
    end
  end
end
