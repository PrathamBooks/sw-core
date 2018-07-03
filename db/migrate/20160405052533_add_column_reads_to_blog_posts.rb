class AddColumnReadsToBlogPosts < ActiveRecord::Migration
  def change
  	add_column :blog_posts, :reads, :integer, :default => 0
  end
end
