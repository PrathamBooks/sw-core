namespace :orgs do
  desc "Generate csv file with details of Organisations"
  task :orgs => :environment do
    CSV.open('/tmp/org_data.csv', 'w') do |c_obj|
      c_obj << ["Id", "Name", "Type", "Country", "number_of_classrooms", "children_impacted", "status", "created_at"]
      Organization.all.each do |o|
        c_obj << [o.id, o.organization_name, o.organization_type, o.country, o.number_of_classrooms, o.children_impacted, o.status, o.created_at.strftime("%Y-%m-%d")]
      end
    end
  end
end

