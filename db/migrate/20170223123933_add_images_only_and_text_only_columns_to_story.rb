class AddImagesOnlyAndTextOnlyColumnsToStory < ActiveRecord::Migration
   def change
    add_column :stories, :images_only, :integer, :default => 0
    add_column :stories, :text_only, :integer, :default => 0
  end
end
