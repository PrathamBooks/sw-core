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

class Page < ActiveRecord::Base

  belongs_to :illustration_crop
  #TODO change it later
  belongs_to :page_template
  belongs_to :story
  acts_as_list scope: :story
  validates :page_template, presence: true
  delegate :illustration, to: :illustration_crop, allow_nil: true
  has_one :google_translated_version

  after_commit :reindex_story

  def reindex_story
    story.reindex unless story.nil?
  end

  def is_story_page?
    type == "StoryPage"
  end

  def is_editable?
    (type == "StoryPage" || type == "FrontCoverPage")
  end

  def update_page_template(page_template,orientation_changed)
    self.update_attributes(:page_template => page_template)
    story.change_orientation(page_template.orientation) if orientation_changed
  end
  def update_page_illustration_crop
    self.update_attributes(:illustration_crop_id => nil)
  end

  def sanitised_content
    Sanitize.clean(content).strip
  end

  def is_front_cover_page?
    type == "FrontCoverPage"
  end

  def is_back_cover_page?
    type == "BackCoverPage"
  end

def story_rating(current_user)
  self.story.ratings.where(:user_id=>current_user.id).collect(&:user_rating).join(" ")
end

def story_comment(current_user)
  self.story.ratings.where(:user_id => current_user.id).collect(&:user_comment).join(" ")
end

end
