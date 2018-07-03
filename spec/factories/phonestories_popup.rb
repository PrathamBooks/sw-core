# == Schema Information
#
# Table name: phonestories_popups
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  popup_opened :boolean          default(FALSE)
#  created_at   :datetime
#  updated_at   :datetime
#

FactoryGirl.define do
  factory :phonestories_popup do
    user
    popup_opened true
  end
end
