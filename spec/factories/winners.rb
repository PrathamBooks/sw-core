# == Schema Information
#
# Table name: winners
#
#  id         :integer          not null, primary key
#  story_id   :integer
#  contest_id :integer
#  story_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
	factory :winner do
		story
		contest
		#story_type ""
	end
end
