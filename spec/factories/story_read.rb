# == Schema Information
#
# Table name: story_reads
#
#  id           :integer          not null, primary key
#  story_id     :integer
#  user_id      :integer
#  is_completed :boolean          default(FALSE)
#  finished_at  :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

FactoryGirl.define do
  factory :story_read do
	user_id 1
	story_id 1
	is_completed true
  end
end