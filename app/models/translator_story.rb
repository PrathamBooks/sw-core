# == Schema Information
#
# Table name: translator_stories
#
#  id                      :integer          not null, primary key
#  start_date              :date
#  story_id                :integer
#  translator_id           :integer
#  translator_story_id     :integer
#  destination_language_id :integer
#

class TranslatorStory < ActiveRecord::Base
  belongs_to :story
  belongs_to :translator_story, :class_name => "Story"
  belongs_to :translator, :class_name => "User"
  belongs_to :translate_language, :class_name => "Language"
  belongs_to :translator_organization, :class_name => "Organization"

  validates :story, presence: true
  validates :translator, presence: true
  validates :translate_language, presence: true
  validates_uniqueness_of :story, :scope => [:translate_language]
end
