# == Schema Information
#
# Table name: language_fonts
#
#  id         :integer          not null, primary key
#  font       :string(255)
#  script     :string(255)
#  created_at :datetime
#  updated_at :datetime
#
FactoryGirl.define do
  factory :language_font do
    sequence(:font) { |n| "font #{n}" }
    sequence(:script) { |n| "script #{n}" }
  end
end
