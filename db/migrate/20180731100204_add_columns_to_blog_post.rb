class AddColumnsToBlogPost < ActiveRecord::Migration
  def change
  	add_column :blog_posts, :add_to_home, :boolean, :default => false
  	add_column :blog_posts, :image_caption, :text
  end
end
