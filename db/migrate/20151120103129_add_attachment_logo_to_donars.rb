class AddAttachmentLogoToDonars < ActiveRecord::Migration
  def self.up
    change_table :donars do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :donars, :logo
  end
end
