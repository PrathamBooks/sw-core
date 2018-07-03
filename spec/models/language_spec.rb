# == Schema Information
#
# Table name: languages
#
#  id                :integer          not null, primary key
#  name              :string(32)       not null
#  is_right_to_left  :boolean          default(FALSE)
#  can_transliterate :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#  script            :string(255)
#  locale            :string(255)
#  bilingual         :boolean          default(FALSE)
#  language_font_id  :integer
#  level_band        :string(255)
#
# Indexes
#
#  index_languages_on_name  (name)
#

require 'rails_helper'

describe Language, :type => :model do
  it { should validate_presence_of :name }
  it { should validate_presence_of :script }
  it { should validate_uniqueness_of(:name).case_insensitive}
  it { should ensure_length_of(:name).is_at_most(32) }

  describe 'default scope' do
    let!(:c1) { Language.create(name: 'Kannada', translated_name: 'Kananda translation', script: 'kn') }
    let!(:c2) { Language.create(name: 'English', translated_name: 'English translation', script: 'en') }
    it 'should order in ascending name' do
      expect(Language.all).to eq [c2,c1]
    end
  end

  describe "is_right_to_left" do 
    it "should default to false" do
      lang = Language.create(name: 'Tamil', translated_name: 'Tamil translation', script: 'ta')
      expect(lang.is_right_to_left?).to eql(false)
    end
  end

  describe "can_transliterate" do 
    it "should default to false" do
      lang = Language.create(name: 'Tamil', translated_name: 'Tamil translation', script: 'ta')
      expect(lang.can_transliterate?).to eql(false)
    end
  end
end
