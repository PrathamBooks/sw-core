namespace :epubs do
  desc "Regenerate old epubs"
  task :generate => :environment do
    puts 'Start generating epubs'
    epub_dates = {}
    File.open("/home/spp_user/epub_dates").each do |l|
      if /(\d\d\d\d)-(\d\d)-(\d\d).*epub\/(\d+)/.match(x)
        epub_dates[$4.to_i] = Date.new($1.to_i, $2.to_i, $3.to_i)
      end
    end
    sc = StoriesController.new
    date = Date.parse("1 feb, 2017")
    stories = Story.where(:status => Story.statuses[:published]).where("created_at < ?", date)
    stories.each do |story|
      if !epub_dates[story.id]  || epub_dates[story.id] < date
        puts "Started generating epub for Story: #{story.id} revision #{story.revision}"
        puts "date: " + (epub_dates[story.id] ? epub_dates[story.id].to_s : "nil")
        puts Time.now
        sc.regenerate_epub(story) rescue puts "Something went wrong"
        puts Time.now
        puts "Ended generating epub for Story: #{story.id}"
      end
    end
    puts 'Ended generating epubs '
  end
end
