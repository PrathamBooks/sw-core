# == Schema Information
#
# Table name: reviewers_languages
#
#  user_id     :integer          not null
#  language_id :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  reviewers_languages_index  (user_id,language_id)
#

class ReviewersLanguage < ActiveRecord::Base
	belongs_to :language
 	belongs_to :user
end
