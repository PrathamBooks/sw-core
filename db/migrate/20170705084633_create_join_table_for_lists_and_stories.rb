class CreateJoinTableForListsAndStories < ActiveRecord::Migration
  def change
    create_join_table :lists, :stories, table_name: :lists_stories do |t|
      t.index [:list_id, :story_id], name: 'lists_stories_index'
    end
  end
end
