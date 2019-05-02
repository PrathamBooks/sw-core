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
#  category_banner_file_name        :string(255)
#  category_banner_content_type     :string(255)
#  category_banner_file_size        :integer
#  category_banner_updated_at       :datetime
#  category_home_image_file_name    :string(255)
#  category_home_image_content_type :string(255)
#  category_home_image_file_size    :integer
#  category_home_image_updated_at   :datetime
#  active_on_home                   :boolean          default(FALSE)
#
# Indexes
#
#  index_story_categories_on_name  (name)
#

require 'rails_helper'

describe StoryCategory, :type => :model do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).case_insensitive}
  it { should ensure_length_of(:name).is_at_most(32) }

  describe 'default scope' do
    let!(:c1) { StoryCategory.create(name: 'Nature') } 
    let!(:c2) { StoryCategory.create(name: 'Animal') }
    it 'should order in ascending name' do
      expect(StoryCategory.all).to eq [c2,c1]
    end
  end
end
