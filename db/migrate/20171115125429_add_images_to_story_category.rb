class AddImagesToStoryCategory < ActiveRecord::Migration
  def up
    add_attachment :story_categories, :category_banner
    add_attachment :story_categories, :category_home_image
  end

  def down
    remove_attachment :story_categories, :category_banner
    remove_attachment :story_categories, :category_home_image
  end
end
