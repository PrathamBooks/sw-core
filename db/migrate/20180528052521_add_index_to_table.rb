class AddIndexToTable < ActiveRecord::Migration
  def change
    add_index :blog_posts, :user_id
    add_index :child_illustrators, :illustration_id
    add_index :illustration_crops, :illustration_id
    add_index :illustration_downloads, [:user_id, :illustration_id]    
    add_index :list_likes, [:list_id, :user_id]
    add_index :list_views, [:list_id, :user_id]
    add_index :lists_stories, [:list_id, :story_id]
    add_index :media_mentions, [:blog_post_id, :user_id]
    add_index :organizations, :email
    add_index :page_templates, :orientation
    add_index :pages, [:story_id, :page_template_id]
    add_index :pages, [:position, :illustration_crop_id]
    add_index :pulled_downs, [:pulled_down_type, :pulled_down_id]
    add_index :ratings, [:rateable_id, :rateable_type]
    add_index :stories, [:language_id, :organization_id]
    add_index :story_downloads, [:story_id, :user_id]
    add_index :story_reads, [:story_id, :user_id]
    add_index :youngsters, [:story_id] 
  end
end
