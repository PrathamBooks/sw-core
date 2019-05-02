# == Schema Information
#
# Table name: illustration_styles
#
#  id         :integer          not null, primary key
#  name       :string(32)       not null
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :style, class: 'IllustrationStyle' do
    sequence(:name) { |n| "Style#{n}" }
  end

end
