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
#
# Indexes
#
#  index_page_templates_on_orientation  (orientation)
#

require 'rails_helper'

describe StoryPageTemplate, :type => :model do
  it{ should validate_presence_of(:name)}
  it{ should validate_uniqueness_of(:name)}

  it{ should validate_presence_of(:orientation)}

  it{ should validate_presence_of(:image_position)}
  it{ should validate_presence_of(:image_dimension)}

  it{ should validate_presence_of(:content_position)}
  it{ should validate_presence_of(:content_dimension)}
end
