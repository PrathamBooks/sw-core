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

class Winner < ActiveRecord::Base
	belongs_to :story
	belongs_to :contest
end
