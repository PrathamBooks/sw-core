class AddAttachmentLogoToPublishers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :users, :logo
  end
end
