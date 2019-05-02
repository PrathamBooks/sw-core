class AddAttachmentBannerImageToBanners < ActiveRecord::Migration
  def self.up
    change_table :banners do |t|
      t.attachment :banner_image
    end
  end

  def self.down
    remove_attachment :banners, :banner_image
  end
end
