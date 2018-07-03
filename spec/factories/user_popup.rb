# == Schema Information
#
# Table name: user_popups
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :user_popup do
    user
    name "its user popup"
  end
end
