class AddOrgIdToStory < ActiveRecord::Migration
  def change
  	add_column :stories, :organization_id, :integer
  end
end
