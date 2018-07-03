# == Schema Information
#
# Table name: banners
#
#  id                        :integer          not null, primary key
#  name                      :string(255)
#  is_active                 :boolean          default(FALSE)
#  link_path                 :string(255)
#  position                  :integer
#  created_at                :datetime
#  updated_at                :datetime
#  banner_image_file_name    :string(255)
#  banner_image_content_type :string(255)
#  banner_image_file_size    :integer
#  banner_image_updated_at   :datetime
#

class Banner < ActiveRecord::Base
  
  has_attached_file :banner_image,
  styles: {
  	:size_1 => "692x",
  	:size_2 => "1064x",
  	:size_3 => "1436x",
  	:size_4 => "1808x",
  	:size_5 => "2180x",
  	:size_6 => "2552x"
  	},
  default_url: "/assets/:style/missing.png",
  storage: Settings.banner_image.storage,
  fog_credentials: "#{Rails.root}/config/fog.yml",
  fog_directory: (Settings.fog.directory rescue nil),
  fog_host: (Settings.fog.host rescue nil),
  path: Settings.fog.banner_image_path

  validates_attachment_content_type :banner_image,  :content_type => ["image/svg+xml","image/jpg", "image/jpeg", "image/png", "image/gif"]

  validates :link_path, presence: true
end
