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
# Indexes
#
#  index_story_reads_on_story_id_and_user_id  (story_id,user_id)
#

class StoryRead < ActiveRecord::Base
	belongs_to :story
	belongs_to :user

  def self.save_story_read(user, story)
    story_read = StoryRead.new
    story_read.story = story
    story_read.user = user
    story_read.save
    return story_read.id
  end
end
