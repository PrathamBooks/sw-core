class AddColumnUserTitleToStories < ActiveRecord::Migration
  def change
    add_column :stories, :user_title, :boolean, :default => false
  end
end
