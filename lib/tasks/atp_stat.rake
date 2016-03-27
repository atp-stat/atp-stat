namespace :atp_stat do
  namespace :player do
    desc "Get player ranking and import them to db."
    task :get, ['range'] => :environment do |task, args|
      players = AtpScraper::Get.singles_ranking(args[:range])
      players.each do |player|
        if Player.exists?(url_id: player[:player_id])
          puts "[Skip] Record Duplicate(#{player[:player_name]})"
          next
        end
        Player.create(
          name: player[:player_name],
          url_name: player[:player_url_name],
          url_id: player[:player_id]
        )
        puts "[Create] Record create(#{player[:player_name]})"
      end
    end
  end
end
