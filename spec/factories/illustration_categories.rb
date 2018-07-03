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

FactoryGirl.define do
  factory :illustration_category do
      sequence(:name) { |n| "Category#{n}" }
  end

end
