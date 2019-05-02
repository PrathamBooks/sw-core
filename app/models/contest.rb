# == Schema Information
#
# Table name: contests
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  start_date          :datetime
#  end_date            :datetime
#  contest_type        :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  is_campaign         :boolean          default(FALSE)
#  tag_name            :string(255)
#  custom_flash_notice :string(255)
#

class Contest < ActiveRecord::Base
  include Shared
  acts_as_taggable
	validates :name, presence: true
	validates :contest_type, presence: true
  #validates :languages, presence: true
	validates :start_date, presence: true
	validates :end_date, presence: true
	validates :tag_name, presence: true

	has_many :stories
	has_and_belongs_to_many :languages
	has_and_belongs_to_many :illustrations
  has_one :story_category
  has_many :winners
  accepts_nested_attributes_for :story_category, reject_if: proc { |attrs| attrs[:name].blank? }
	def to_param
    url_slug(id, name.parameterize)
  end

  def contest_languages
  	languages.collect(&:name).join(',')
  end

  def is_running?

  	today_date = DateTime.now.strftime("%Y-%m-%d")
  	if today_date >= self.start_date.strftime("%Y-%m-%d") && today_date <= self.end_date.strftime("%Y-%m-%d")
  		return true
  	else
  		return false
  	end
  end
end
