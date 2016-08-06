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
      calculate(args[:player_name], args[:year])
    end

    desc "Calculate player status for all players"
    task :calculate_status_all_players, ['year'] => :environment do |task, args|
      Player.select("name").each do |player|
        calculate(player.name, args[:year])
      end
    end

    def calculate(name, year)
      player = {
        :year => year,
        :player_name => name,
        :explosive => Activity.calculate_status_explosive(name, year),
        :stability => Activity.calculate_status_stability(name, year),
        :mentality => Activity.calculate_status_mentality(name, year),
        :momentum  => Activity.calculate_status_momentum(name, year),
        :toughness => Activity.calculate_status_toughness(name, year),
        :vs_top10_win  => Activity.count_vs_top10(name, year, 'W'),
        :vs_top10_loss => Activity.count_vs_top10(name, year, 'L')
      }

      player_status = PlayerStatus.where(:year => player[:year], :player_name => player[:player_name])
      if player_status.exists?
          player_status.update_all(player)
          puts "Record update(#{player[:player_name]},#{player[:year]})"
      else
        begin
          PlayerStatus.create(player)
          puts "Record create(#{player[:player_name]},#{player[:year]})"
        rescue => e
          puts "Record create Error(#{player[:player_name]},#{player[:year]})"
        end
      end
    end
  end
end
