# == Schema Information
#
# Table name: story_categories
#
#  id                               :integer          not null, primary key
#  name                             :string(32)       not null
#  created_at                       :datetime
#  updated_at                       :datetime
#  private                          :boolean          default(FALSE)
#  contest_id                       :integer
#  active_on_home                   :boolean          default(FALSE)
#  category_banner_file_name        :string(255)
#  category_banner_content_type     :string(255)
#  category_banner_file_size        :integer
#  category_banner_updated_at       :datetime
#  category_home_image_file_name    :string(255)
#  category_home_image_content_type :string(255)
#  category_home_image_file_size    :integer
#  category_home_image_updated_at   :datetime
#  card_link                        :text
#
# Indexes
#
#  index_story_categories_on_name  (name)
#

FactoryGirl.define do
  factory :story_category do
    sequence(:name) { |n| "Category #{n}" }
    active_on_home true
  end

  factory :story_category_with_banner_and_home_image, class: StoryCategory do
    name "Wildlife"
    active_on_home true
    category_banner Rack::Test::UploadedFile.new('spec/photos/forest.jpg', 'image/jpg')
    category_home_image Rack::Test::UploadedFile.new('spec/photos/logo.png', 'image/png')
  end
end
