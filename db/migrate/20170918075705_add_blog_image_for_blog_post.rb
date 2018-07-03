class AddBlogImageForBlogPost < ActiveRecord::Migration
  def change
  	add_attachment :blog_posts, :blog_post_image
  end
end
