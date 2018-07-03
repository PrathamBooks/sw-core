namespace :person do
  desc "Create Users for persons who dont have any"
  task create_users: :environment do
    noUserPersons = Person.where(user_id: nil)
    noUserPersons.each do |p|
      u = User.new
      u.first_name = p.first_name
      u.last_name = p.last_name
      u.email = "#{p.name.gsub(/\s+/, '')}@sample.com"
      u.password = "password"
      u.skip_confirmation!
      u.save!
      p.user_id = u.id 
      p.save!
    end
  end

  # desc "Delete Empty Persons"
  # task delete_persons: :environment do
  #   Person.all.each do |p|
  #     if(p.illustrations.count ==0)
  #       p.delete
  #     end
  #   end
  # end

end
