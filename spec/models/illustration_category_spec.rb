# == Schema Information
#
# Table name: illustration_categories
#
#  id         :integer          not null, primary key
#  name       :string(32)       not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_illustration_categories_on_name  (name)
#

require 'rails_helper'

describe IllustrationCategory, :type => :model do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).case_insensitive}
  it { should ensure_length_of(:name).is_at_most(32) }

  describe 'default scope' do
    let!(:c1) { IllustrationCategory.create(name: 'Nature') } 
    let!(:c2) { IllustrationCategory.create(name: 'Animal') }
    it 'should order in ascending name' do
      expect(IllustrationCategory.all).to eq [c2,c1]
    end
  end
end
