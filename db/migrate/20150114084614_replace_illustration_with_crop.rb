class ReplaceIllustrationWithCrop < ActiveRecord::Migration
  def change
    remove_column :pages,:illustration_id
    add_column :pages, :illustration_crop_id, :integer
  end
end
