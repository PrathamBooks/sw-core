# == Schema Information
#
# Table name: translation_feedbacks
#
#  id         :integer          not null, primary key
#  story_id   :integer
#  user_id    :integer
#  feedback   :integer
#  created_at :datetime
#  updated_at :datetime
#

class TranslationFeedback < ActiveRecord::Base
  belongs_to :user
  belongs_to :story
end
