# == Schema Information
#
# Table name: page_templates
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  orientation       :string(255)
#  image_position    :string(255)
#  content_position  :string(255)
#  image_dimension   :integer
#  content_dimension :integer
#  created_at        :datetime
#  updated_at        :datetime
#  type              :string(255)
#

FactoryGirl.define do
  factory :story_page_template do
    sequence(:name) { |n| "Story Page Template #{n}" }
    orientation "landscape"
    image_position "left"
    content_position "right"
    image_dimension 70.0
    content_dimension 30.0
  end
end
