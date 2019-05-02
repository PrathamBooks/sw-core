class AddAttachmentStorycardImageToIllustrationCrops < ActiveRecord::Migration
  def self.up
    change_table :illustration_crops do |t|
      t.attachment :storycard_image
    end
  end

  def self.down
    remove_attachment :illustration_crops, :storycard_image
  end
end
