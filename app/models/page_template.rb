# == Schema Information
#
# Table name: page_templates
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  orientation       :string(255)
#  image_position    :string(255)
#  content_position  :string(255)
#  image_dimension   :float
#  content_dimension :float
#  created_at        :datetime
#  updated_at        :datetime
#  type              :string(255)
#  default           :boolean          default(FALSE)
#  origin_url        :string(255)
#  uuid              :string(255)
#
# Indexes
#
#  index_page_templates_on_orientation  (orientation)
#

class PageTemplate < ActiveRecord::Base
  scope :default, -> { where(default: true) }
  scope :of_orientation, ->(orientation) { where("orientation = ?", orientation) }

  after_create :add_uuid_and_origin_url

  def add_uuid_and_origin_url
    if self.uuid == nil && self.origin_url == nil
      self.uuid = "#{Settings.org_info.prefix}-#{self.id}"
      self.origin_url = Settings.org_info.url
      self.save!
    elsif self.uuid == nil
      self.uuid = "#{Settings.org_info.prefix}-#{self.id}"
      self.save!
    elsif self.origin_url == nil
      self.origin_url = Settings.org_info.url
      self.save!
    end
  end
  
  def get_similar_templates
    case self.class.to_s
    when "StoryPageTemplate"
      StoryPageTemplate.all
    when "FrontCoverPageTemplate"
      FrontCoverPageTemplate.all
    when "BackInnerCoverPageTemplate"
      BackInnerCoverPageTemplate.all
    when "BackCoverPageTemplate"
      BackCoverPageTemplate.all
    when "DedicationPageTemplate"
      DedicationPageTemplate.all
    end
  end

  def scaled_dimension_for_size(size)
    !(image_position == "left" || image_position == "right") ?
      size :
      size * image_dimension/100.0
  end

  def image_mandatory?
    !image_position.nil? && image_position != 'nil'
  end

  # max illustrartor character limit on front cover page
  def max_limit
    if image_dimension > 50
      orientation == "landscape" ? 150 : 100 
    else
      orientation == "landscape" ? 350 : 250
    end
  end

  def is_full_text_template?
    name == "sp_v_c100" || name == "sp_h_c100"
  end

end
