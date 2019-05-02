namespace :lists do
  desc "Create default My Library list for all users."
  task create_my_library_lists: :environment do
  	User.all.each do |u|
  		list = List.new
  		list.title = "My Library"
  		list.user_id = u.id
      list.can_delete = false  		
      list.save!
  	end
  end

end
