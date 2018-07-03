# == Schema Information
#
# Table name: illustration_crops
#
#  id                 :integer          not null, primary key
#  illustration_id    :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  image_processing   :boolean
#  crop_details       :text
#  image_meta         :text
#  storage_location   :string(255)
#  smart_crop_details :text
#
# Indexes
#
#  index_illustration_crops_on_illustration_id  (illustration_id)
#

FactoryGirl.define do
  factory :illustration_crop do
    illustration { create(:illustration) }
  end

end
