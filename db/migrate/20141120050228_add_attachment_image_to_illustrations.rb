class AddAttachmentImageToIllustrations < ActiveRecord::Migration
  def self.up
    change_table :illustrations do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :illustrations, :image
  end
end
