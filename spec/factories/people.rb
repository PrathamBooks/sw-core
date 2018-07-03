# == Schema Information
#
# Table name: people
#
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  created_at              :datetime
#  updated_at              :datetime
#  created_by_publisher_id :integer
#  first_name              :string(255)
#  last_name               :string(255)
#
# Indexes
#
#  index_people_on_created_by_publisher_id  (created_by_publisher_id)
#

FactoryGirl.define do
  factory :person do
    sequence(:first_name) { |n| "User first name #{n}" }
    sequence(:last_name) { |n| "User last name #{n}" }
  end
  factory :person_with_account, class: Person do
    sequence(:first_name) { |n| "User first name #{n}" }
    sequence(:last_name) { |n| "User last name #{n}" }
    user { create(:user) }
  end
end
