# == Schema Information
#
# Table name: illustrations
#
#  id                       :integer          not null, primary key
#  name                     :string(255)      not null
#  created_at               :datetime
#  updated_at               :datetime
#  image_file_name          :string(255)
#  image_content_type       :string(255)
#  image_file_size          :integer
#  image_updated_at         :datetime
#  uploader_id              :integer
#  attribution_text         :text
#  license_type             :integer
#  image_processing         :boolean
#  flaggings_count          :integer
#  copy_right_year          :integer
#  image_meta               :text
#  cached_votes_total       :integer          default(0)
#  reads                    :integer          default(0)
#  is_pulled_down           :boolean          default(FALSE)
#  publisher_id             :integer
#  copy_right_holder_id     :integer
#  image_mode               :boolean          default(FALSE)
#  storage_location         :string(255)
#  is_bulk_upload           :boolean          default(FALSE)
#  smart_crop_details       :text
#  organization_id          :integer
#  org_copy_right_holder_id :integer
#  album_id                 :integer
#
# Indexes
#
#  index_illustrations_on_album_id            (album_id)
#  index_illustrations_on_cached_votes_total  (cached_votes_total)
#

FactoryGirl.define do
  factory :illustration do
    sequence(:name) { |n| "Illustration#{n}" }
    # illustrator_id 1
    image  Rack::Test::UploadedFile.new('spec/photos/forest.jpg', 'image/jpg')
    illustrators { [create(:person)] }
    license_type 'CC BY 4.0'
    uploader { create(:user) }
    styles {[create(:style)]}
    categories {[create(:illustration_category)]}
    attribution_text "This illustration is attributed to no one in particular."
  end

  factory :footer_image do
    illustration
  end
end
