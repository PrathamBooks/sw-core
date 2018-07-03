# == Schema Information
#
# Table name: lists
#
#  id              :integer          not null, primary key
#  title           :string(255)
#  description     :string(1000)
#  user_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer
#  status          :integer          default(0), not null
#  synopsis        :string(750)
#  can_delete      :boolean          default(TRUE)
#  is_default_list :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :list do
    sequence (:title) { |n| "List Title #{n}"}
    description "List Description"
    synopsis "List Description"
    status "published"
    categories {[FactoryGirl.create(:list_category)]}
    organization
  end
  factory :list_category do
    sequence(:name) { |n| "Activity Books#{n}" }
    sequence(:translated_name) { |n| "Translated Activity Books#{n}" }
  end
  factory :lists_story do
    list
    story
    how_to_use "Test story tip"
  end
  factory :list_view do
    user
    list
  end
  factory :list_like do
    user
    list
  end
end
