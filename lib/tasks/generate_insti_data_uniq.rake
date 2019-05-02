namespace :db do
  desc "Create org users from csv"
  task :create_uniq_orgs => :environment do
    csv_text = File.read("#{Rails.root}/unique_insti_data.csv")
    csv = CSV.parse(csv_text, :headers => true)
    saved_org = nil
    saved_orgs = []
    csv.each_with_index do |row, index|
      city = row[2] ? row[2].strip : ""
      country = row[3].strip
      org_name = row[1]
      # email = row[4].strip
      org = Organization.where(:organization_name => org_name, :country => country).first
      if !org
        org = Organization.new(organization_name: org_name, country:country, children_impacted: 0,number_of_classrooms: 0, status: "New")
        puts "Created new org #{org_name}"
      end
      begin
       insti_user = InstitutionalUser.find(row[0])
      rescue => e
       puts e.message
       insti_user = nil
      end
      if !insti_user
        puts "Insti User with id #{row[0]} not found"
        next
      end
      u = insti_user.user
      if !u
        puts "User with email #{email} not found"
        next
      end
      puts "Changing user #{u.email}"
      puts "Org id #{org.id}"
      org.created_at = u.institutional_user.created_at
      org.updated_at = u.institutional_user.updated_at
      org.children_impacted = u.institutional_user.children_impacted
      org.number_of_classrooms = u.institutional_user.number_of_classrooms
      org.save
      u.organization = org
      u.city = city
      u.org_registration_date = u.institutional_user.created_at
      u.save
    end[0]
    puts saved_orgs
  end
end

