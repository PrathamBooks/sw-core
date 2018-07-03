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

class StoryPage < Page

  # validates :illustration, presence: true
  # validates :content, presence: true, if: :validate_content
  validates :story, presence: true

  # def validate_content
  # 	story.try(:published?) && page_template.try(:content_position) != 'nil'
  # end
end
