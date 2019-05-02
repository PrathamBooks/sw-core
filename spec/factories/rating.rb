# == Schema Information
#
# Table name: reviewer_comments
#
#  id              :integer          not null, primary key
#  story_id        :integer
#  user_id         :integer
#  story_rating    :integer
#  language_rating :integer
#  created_at      :datetime
#  updated_at      :datetime
#  rating          :integer
#  language_id     :integer
#  comments        :text
#

FactoryGirl.define do
  factory :reviewer_comment do
  	user
  	story
  	language
  	story_rating 3
  	language_rating 3
  	rating 5
  	comments "Good story"
  end
end
