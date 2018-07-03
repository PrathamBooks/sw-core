namespace :users do
  desc "Generate data for creators"
  task :creators, [:csv_file] => :environment do |t, args|
    creators = Story.all.map{|s| s.authors}.flatten.uniq
    CSV.open(args[:csv_file], "w") do |c_obj|
      creators.each do |c|
        c_obj << [c.id, c.name, c.email]
      end
    end
  end
end

namespace :users do
  desc "Generate data for downloaders"
  task :downloaders, [:csv_file] => :environment do |t, args|
    downloaders = User.all.find_all{|u| u.story_downloads.count > 0}
    CSV.open(args[:csv_file], "w") do |c_obj|
      c_obj << ["Id", "Name", "Email", "City", "Org Name", "Country", "Classrooms", "Children", "Downloads", "First Date", "Types", "Languages"]
      downloaders.each do |c|
        first_download = StoryDownload.find_by_sql("SELECT * FROM story_downloads WHERE user_id = " + c.id.to_s + " ORDER BY created_at ASC LIMIT 1")[0]
        first_download_date = first_download.created_at.to_date
        ndownloads = c.story_downloads.map{|d| d.stories.count > 0 ? d.stories.count : 1}.sum
        download_types = c.story_downloads.map{|d| d.download_type}.uniq.join(", ")
        languages = Set.new
        c.story_downloads.each do |d|
          if d.stories.count > 0
            d.stories.each do |s|
              languages.add(s.language.name)
            end
          else
            if d.story_id
              languages.add(Story.find(d.story_id).language.name)
            end
          end
        end
        if c.organization
          c_obj << [c.id, c.name, c.email, c.city, c.organization.organization_name, c.organization.country, c.organization.number_of_classrooms, c.organization.children_impacted, ndownloads, first_download_date, download_types, languages.to_a.join(', ')]
        else
          c_obj << [c.id, c.name, c.email, c.city, "", "", "", "", ndownloads, first_download_date, download_types, languages.to_a.join(', ')]
        end
      end
    end
  end
end
