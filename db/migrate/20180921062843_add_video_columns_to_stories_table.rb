class AddVideoColumnsToStoriesTable < ActiveRecord::Migration
  def change
    add_column :stories, :is_video, :boolean, default: false
    add_column :stories, :video_status, :integer
    add_column :stories, :youtube_link, :string
  end
end
