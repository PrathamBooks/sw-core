class AddLogoToBlogPost < ActiveRecord::Migration
  def change
  	add_attachment :blog_posts, :logo
  end
end
