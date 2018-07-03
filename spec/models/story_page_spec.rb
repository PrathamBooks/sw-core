# == Schema Information
#
# Table name: pages
#
#  id                   :integer          not null, primary key
#  page_template_id     :integer
#  story_id             :integer
#  content              :text
#  crop_height          :float
#  crop_width           :float
#  position             :integer
#  created_at           :datetime
#  updated_at           :datetime
#  type                 :string(255)
#  illustration_crop_id :integer
#
# Indexes
#
#  index_pages_on_position_and_illustration_crop_id  (position,illustration_crop_id)
#  index_pages_on_story_id_and_page_template_id      (story_id,page_template_id)
#

require 'rails_helper'

describe StoryPage, :type => :model do
  it {should validate_presence_of(:page_template)}
  it {should validate_presence_of(:story)}
  # it {should validate_presence_of(:content)}
end
