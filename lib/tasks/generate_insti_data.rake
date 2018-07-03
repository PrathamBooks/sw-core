namespace :users do
  desc "Generate csv file with details of Institutional Users"
  task :orgs => :environment do
    info = []
    info << ["Name", "City", "Country", "User Email", "User Name"]
    InstitutionalUser.all.each do |i|
      info << [i.id, i.organization_name, i.city, i.country, i.user.email, i.user.name]
    end
    CSV.open('/tmp/insti_data.csv', 'w') do |c_obj|
      info.each do |i|
        c_obj << i
      end
    end
  end
end

