namespace :db do
  desc "Create publisher organizations"
  task :create_pub_orgs => :environment do
    Publisher.all.each do|pub|
      org = Organization.new(organization_name: pub.first_name, country:"India", children_impacted: 0,number_of_classrooms: 0, status: "Approved", organization_type: "Publisher", email: pub.email)
      org.save
      puts "#{org.organization_name} Created"
      puts "publisher id id :::: #{pub.id}"
      pub.organization = org
      pub.org_registration_date = org.created_at
      pub.organization_roles = "publisher"
      pub.save
      puts "#{pub.organization.organization_name} is assigned and role is #{pub.organization_roles}"
      stories = Story.where(:publisher_id => pub.id)
      stories.each do|story|
        story.organization = pub.organization
        puts "story org is #{story.organization_id}"
        story.save
      end
    end
  end
end
