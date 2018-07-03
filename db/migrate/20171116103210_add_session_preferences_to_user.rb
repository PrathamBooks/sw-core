class AddSessionPreferencesToUser < ActiveRecord::Migration
  def change
  	add_column :users, :session_preferences, :string
  end
end
