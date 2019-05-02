class UpdatePersonFirstNameLastName < ActiveRecord::Migration
  def change
  	User.all.each do |user|
  		user.person.update_attributes({first_name: user.first_name,last_name: user.last_name}) if user.person.present?
  	end
  end
end
