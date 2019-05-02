class AddColumnRevisionToStories < ActiveRecord::Migration
  def change
  	add_column :stories, :revision, :integer
  end
end
