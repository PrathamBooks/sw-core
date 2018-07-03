class AddPreferenceToUsers < ActiveRecord::Migration
  def change
  	 add_column :users, :email_preference, :boolean, default: false
  end
end
