# == Schema Information
#
# Table name: contests
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  start_date          :datetime
#  end_date            :datetime
#  contest_type        :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  is_campaign         :boolean          default(FALSE)
#  tag_name            :string(255)
#  custom_flash_notice :string(255)
#

FactoryGirl.define do
  factory :contest do
  	name "contest_story"
  	start_date "20-5-2015"
  	end_date "30-5-2015"
  	contest_type "contest"
  	is_campaign false
  	tag_name "contest/campaign_tag"
  end
end
