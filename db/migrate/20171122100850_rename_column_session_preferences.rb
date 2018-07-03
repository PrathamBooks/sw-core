class RenameColumnSessionPreferences < ActiveRecord::Migration
  def change
  	rename_column :users, :session_preferences, :locale_preferences
  end
end
