namespace :tmp_work do
  desc "convert score"
  task :convert_score => :environment do |task|
    Activity.all.each do |activity|
      puts "#{activity.id} / #{AtpScraper::Utility.convert_score(activity.score)}"
      activity.update(score: AtpScraper::Utility.convert_score(activity.score))
    end
  end
end
