# == Schema Information
#
# Table name: pulled_downs
#
#  id               :integer          not null, primary key
#  pulled_down_type :string(255)
#  pulled_down_id   :integer
#  reason           :text
#  created_at       :datetime
#  updated_at       :datetime
#
# Indexes
#
#  index_pulled_downs_on_pulled_down_type_and_pulled_down_id  (pulled_down_type,pulled_down_id)
#

FactoryGirl.define do
  factory :pulled_down do
    
  end

end
