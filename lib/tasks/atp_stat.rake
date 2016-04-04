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
    task :register_weekly_job => :environment do |task, args|
      players = Player.all
      players.each do |player|
        ActivityJob.create(
          player_name: player.name,
          player_id: player.id,
          year: Date.today.year.to_s
        )
        puts "[Job Created] #{player.name}"
      end
    end
  end
end
