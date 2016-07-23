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
      player = {
        :year => args[:year],
        :player_name => args[:player_name],
        :explosive_value => Activity.calculate_status_explosive(args[:player_name],args[:year]),
        :stability_value => Activity.calculate_status_stability(args[:player_name],args[:year]),
        :mentality_value => Activity.calculate_status_mentality(args[:player_name],args[:year]),
        :momentum_value => Activity.calculate_status_momentum(args[:player_name],args[:year]),
        :toughness_value => Activity.calculate_status_toughness(args[:player_name],args[:year])
      }

      player_status = PlayerStatus.where(:year => player[:year], :player_name => player[:player_name])
      if player_status.exists?
          player_status.update_all(
            stability: player[:stability_value],
            toughness: player[:toughness_value],
            mentality: player[:mentality_value],
            explosive: player[:explosive_value],
            momentum: player[:momentum_value]
          )
          puts "[Updated] Record create(#{player[:player_name]},#{player[:year]})"
      else
        begin
          PlayerStatus.create(
            year: player[:year],
            player_name: player[:player_name],
            stability: player[:stability_value],
            toughness: player[:toughness_value],
            mentality: player[:mentality_value],
            explosive: player[:explosive_value],
            momentum: player[:momentum_value]
          )
          puts "[Calculated] Record create(#{player[:player_name]},#{player[:year]})"
        rescue => e
          puts "[Skip] Record create Error(#{player[:player_name]},#{player[:year]})"
          next
        end
      end
    end

    desc "Calculate player status for all players"
    task :calculate_status_all_players, ['year'] => :environment do |task, args|
      players = Player.select("name")
      players.each do |player|
        player_name = player.name
        player_data = {
          :year => args[:year],
          :player_name => player_name,
          :explosive_value => Activity.calculate_status_explosive(player_name,args[:year]),
          :stability_value => Activity.calculate_status_stability(player_name,args[:year]),
          :mentality_value => Activity.calculate_status_mentality(player_name,args[:year]),
          :momentum_value => Activity.calculate_status_momentum(player_name,args[:year]),
          :toughness_value => Activity.calculate_status_toughness(player_name,args[:year])
        }
        player_status = PlayerStatus.where(:year => player_data[:year], :player_name => player_data[:player_name])
        if player_status.exists?
            player_status.update_all(
              stability: player_data[:stability_value],
              toughness: player_data[:toughness_value],
              mentality: player_data[:mentality_value],
              explosive: player_data[:explosive_value],
              momentum: player_data[:momentum_value]
            )
            puts "[Updated] Record create(#{player_data[:player_name]},#{player_data[:year]})"
        else
          begin
            PlayerStatus.create(
              year: player_data[:year],
              player_name: player_data[:player_name],
              stability: player_data[:stability_value],
              toughness: player_data[:toughness_value],
              mentality: player_data[:mentality_value],
              explosive: player_data[:explosive_value],
              momentum: player_data[:momentum_value]
            )
            puts "[Calculated] Record create(#{player_data[:player_name]},#{player_data[:year]})"
          rescue => e
            puts "[Skip] Record create Error(#{player_data[:player_name]},#{player_data[:year]})"
            next
          end
        end
      end
    end

    desc "Calculate players status for all players"
    task :calculate_status_all, ['year'] => :environment do |task, args|
      players = Player.select("name")
      players.each do |player|
        player_name = player.name
        Activity.calculate_status_explosive(player_name,args[:year])
        Activity.calculate_status_stability(player_name,args[:year])
        Activity.calculate_status_mentality(player_name,args[:year])
      end
    end

  end
end
