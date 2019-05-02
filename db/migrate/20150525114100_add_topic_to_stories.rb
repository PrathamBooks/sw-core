class AddTopicToStories < ActiveRecord::Migration
  def change
    add_column :stories, :topic_id, :integer,null: true
  end
end
