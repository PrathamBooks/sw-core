namespace :db do
  desc "Create org users from csv"
  task :org_profile => :environment do
    csv_text = File.read("#{Rails.root}/org_profiles.csv")
    csv = CSV.parse(csv_text, :headers => true)
    csv.each_with_index do |row, index|
      org = Organization.find_by_organization_name(row[0].strip)
      if org
         begin
          org.logo = File.open("#{Rails.root}/recontentpartnerlogos/"+row[1].strip) if row[1]
          org.website = row[2].strip if row[2]
          org.email = row[3].strip if row[3]
          org.facebook_url = row[4].strip if row[4]
          org.twitter_url = row[5].strip if row[5]
          org.description = row[6].strip if row[6]
          org.save!
          puts org.logo.url
        rescue Exception => e
          puts e
          puts "org not found"
        end  
      end
    end
  end
end