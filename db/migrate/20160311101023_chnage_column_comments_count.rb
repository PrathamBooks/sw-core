class ChnageColumnCommentsCount < ActiveRecord::Migration
  def change
    change_column :blog_posts, :comments_count, :integer, :default => 0
  end
end
