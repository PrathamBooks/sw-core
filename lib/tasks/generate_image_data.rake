namespace :stories do
  desc "Generate published story stats"
  task :image_data => :environment do
    stories = Story.where(status: 1).where(ancestry:nil)
    stories.each do |story|
      illustrations = []
      story.pages.each do |page|
        if page.illustration_crop
          illustrations.append(page.illustration_crop.illustration.id).to_s
        end
      end
      puts story.id.to_s + ":" + illustrations.join(',')
    end
  end
end
