class CreateIllustrationCrops < ActiveRecord::Migration
  def change
    create_table :illustration_crops do |t|
      t.belongs_to :illustration
      t.attachment :image
      t.timestamps
    end
  end
end
