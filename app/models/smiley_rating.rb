# == Schema Information
#
# Table name: smiley_ratings
#
#  id         :integer          not null, primary key
#  story_id   :integer
#  user_id    :integer
#  reaction   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class SmileyRating < ActiveRecord::Base
   validates :story_id, presence: true
   validates :reaction, presence: true
   belongs_to :story
   belongs_to :user
end
