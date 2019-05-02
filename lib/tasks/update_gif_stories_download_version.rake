namespace :db do
  desc "Import download version of gif stories from csv file"
  task :update_gif_stories_download_version => :environment do
    csv_text = File.read("#{Rails.root}/tmp/gif_stories_download_version.csv")
    csv = CSV.parse(csv_text, :headers => true)
    csv.each_with_index do |row, index|
      original_story_slug =  row["Original Story"].split("/").last
      original_story = Story.find_by_id original_story_slug
      if original_story.nil?
        p "#{original_story_slug} slug is incorrect"
        next
      end
      download_version_story_slug = row["Download Version Story"].split("/").last
      download_version_story = Story.find_by_id download_version_story_slug
      if original_story.nil?
        p "#{download_version_story_slug} slug is incorrect"
        next
      end
      original_story.update_attribute(:download_version, download_version_story.id)
      p "Successfully updated download version of #{original_story_slug} with #{download_version_story_slug}"
    end
  end
end