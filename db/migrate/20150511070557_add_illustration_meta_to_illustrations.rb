class AddIllustrationMetaToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :image_meta, :text
  end
end
