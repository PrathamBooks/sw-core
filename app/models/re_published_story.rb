# == Schema Information
#
# Table name: re_published_stories
#
#  id              :integer          not null, primary key
#  story_id        :integer
#  previous_status :integer
#  published_at    :datetime
#  user_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class RePublishedStory < ActiveRecord::Base
	belongs_to :story
	belongs_to :user
end
