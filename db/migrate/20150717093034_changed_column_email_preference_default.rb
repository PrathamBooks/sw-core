class ChangedColumnEmailPreferenceDefault < ActiveRecord::Migration
  def change
  	change_column :users, :email_preference, :boolean, default: true
  end
end
