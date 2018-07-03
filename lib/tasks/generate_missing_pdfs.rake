namespace :pdfs do
  desc "Regenerate old pdfs"
  task :generate => :environment do
    puts 'Start generating pdfs'
    low_pdf_dates = {}
    File.open("/home/spp_user/low_pdf_dates").each do |l|
      if /(\d\d\d\d)-(\d\d)-(\d\d).*low\/(\d+)/.match(l)
        low_pdf_dates[$4.to_i] = Date.new($1.to_i, $2.to_i, $3.to_i)
      end
    end
    high_pdf_dates = {}
    File.open("/home/spp_user/high_pdf_dates").each do |l|
      if /(\d\d\d\d)-(\d\d)-(\d\d).*high\/(\d+)/.match(l)
        high_pdf_dates[$4.to_i] = Date.new($1.to_i, $2.to_i, $3.to_i)
      end
    end
    sc = StoriesController.new
    stories = Story.where(status:1)
    puts "Checking pdfs for #{stories.size} stories"
    # stories = Story.where(:status => Story.statuses[:published]).where("created_at < ?", date)
    stories.each do |story|
      if !low_pdf_dates[story.id] || !high_pdf_dates[story.id]
        puts "Started generating pdf for Story: #{story.id}"
        puts Time.now
        sc.regenerate_pdf(story) rescue puts "Something went wrong"
        puts Time.now
        puts "Ended generating pdf for Story: #{story.id}"
      else
        puts "Story id #{story.id} exists, #{low_pdf_dates[story.id]}, #{high_pdf_dates[story.id]}"
      end

    end
    puts 'Ended generating pdfs '
  end
end
