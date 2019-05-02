# == Schema Information
#
# Table name: illustration_styles
#
#  id         :integer          not null, primary key
#  name       :string(32)       not null
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe IllustrationStyle, :type => :model do
  it{ should validate_presence_of(:name)}
  it{ should validate_uniqueness_of(:name)}
  it{ should ensure_length_of(:name).is_at_most(32)}
end
