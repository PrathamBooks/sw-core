class RemoveLogoFromBlogPost < ActiveRecord::Migration
  def change
  	remove_attachment :blog_posts, :logo
  end
end
