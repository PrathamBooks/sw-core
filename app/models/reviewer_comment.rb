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

class ReviewerComment < ActiveRecord::Base

  STORY_RATINGS ={'Fantastic! Highly recommend it.' => 5, 'Good. Would recommend it.' => 4, "It's alright." => 3, 'Poor quality' => 2, "Terrible!" => 1}
  LANGUAGE_RATINGS = {'Fantastic! Highly recommend it. ' => 5, 'Good. Would recommend it. ' => 4, "It's alright. " => 3, 'Poor quality ' => 2, "Terrible! " => 1}
  CONTENT_TYPES = {'Obscene language' => 0, 'Inappropriate ideas and themes' => 1, 'Factual errors' => 2}
  IMAGE_QUALITIES = {'Blurred images' => 0, 'Copyrighted images (images with watermarks or logos)' => 1, 'Obscene images' => 2}
  OVERALL_EXPERIENCE = {'Text flowing out of story page' => 1, 'Language mismatch' => 2, 'Reading level mismatch' => 3, 'Incomplete Story' => 4}

  enum story_rating: STORY_RATINGS
  enum language_rating: LANGUAGE_RATINGS
  enum content_type: CONTENT_TYPES
  enum image_quality: IMAGE_QUALITIES
  enum overall_experience: OVERALL_EXPERIENCE
  validates :story_rating, presence: true
  validates :language_rating, presence: true
  validates :rating, presence: true
  belongs_to :story
  belongs_to :user


  def self.get_reviewed_stories
    reviewer_comments = ReviewerComment.includes(:user, :story => :language).where(:created_at => DateTime.now.utc.beginning_of_day .. DateTime.now.utc.end_of_day)
    if reviewer_comments.count != 0
      content_managers = User.content_manager.collect(&:email).join(",")
      UserMailer.reviewer_rating_comment(content_managers,reviewer_comments,DateTime.now.strftime("%b %d, %Y")).deliver
    end
  end

  def self.get_reviewed_stories_weekly
   reviewer_comments = ReviewerComment.includes(:user, :story => :language).where(:created_at => 1.week.ago.beginning_of_week .. 1.week.ago.end_of_week)
    if reviewer_comments.count != 0
      content_managers = User.content_manager.collect(&:email).join(",")
      UserMailer.reviewer_rating_comment(content_managers,reviewer_comments,DateTime.now.strftime("%b %d, %Y")).deliver
    end
  end

  def self.analytics_story_keys(stories)
    (stories[0][:data].keys+stories[1][:data].keys+stories[2][:data].keys+stories[3][:data].keys+stories[4][:data].keys).uniq
  end

  def self.analytics_language_story_keys(language_stories)
    (language_stories[0][:data].keys+language_stories[1][:data].keys+language_stories[2][:data].keys+language_stories[3][:data].keys+language_stories[4][:data].keys).uniq
  end

end
