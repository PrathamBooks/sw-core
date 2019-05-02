class CreateJoinTableAuthorsStories < ActiveRecord::Migration
  def change
    create_join_table :users, :stories, table_name: :authors_stories do |t|
      t.index [:user_id, :story_id], name: 'author_story_index'
    end
  end
end
