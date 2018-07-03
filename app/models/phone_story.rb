# == Schema Information
#
# Table name: phone_stories
#
#  id         :integer          not null, primary key
#  story_id   :integer
#  text       :text
#  link       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class PhoneStory < ActiveRecord::Base
	belongs_to :story
end
