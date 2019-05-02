# == Schema Information
#
# Table name: recommendations
#
#  id                 :integer          not null, primary key
#  recommendable_id   :integer
#  recommendable_type :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

FactoryGirl.define do
	factory :recommendation do
		sequence(:recommendable_id) { |n| "#{n}"}
		sequence(:recommendable_type) { |n| "recommendable_type #{n}" }
	end
end
