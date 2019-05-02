class AddListIdToStoryDownloads < ActiveRecord::Migration
  def change
  	add_column :story_downloads, :list_id, :integer
  end
end
