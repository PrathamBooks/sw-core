class CreateJoinTableStoriesDownloads < ActiveRecord::Migration
  def change
  	create_join_table :story_downloads, :stories, table_name: :stories_downloads do |t|
      t.index [:story_download_id, :story_id], name: 'stories_downloads_index'
    end
  end
end

