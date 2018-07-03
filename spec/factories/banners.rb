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
FactoryGirl.define do
 factory :banner do
   name "Banner_1_small_new.jpg"
   link_path "www.google.com"
   is_active true
   banner_image  Rack::Test::UploadedFile.new("#{Rails.root}/illustrations/image_8.jpg", 'image/jpg')
   position 1
 end
end


