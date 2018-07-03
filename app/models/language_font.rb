# == Schema Information
#
# Table name: language_fonts
#
#  id         :integer          not null, primary key
#  font       :string(255)
#  script     :string(255)
#  created_at :datetime
#  updated_at :datetime
#  origin_url :string(255)
#  uuid       :string(255)
#

class LanguageFont < ActiveRecord::Base

	validates :script, presence: true
	validates :font, presence: true

  has_many :languages
  
  after_create :add_uuid_and_origin_url

  def add_uuid_and_origin_url
    if self.uuid == nil && self.origin_url == nil
      self.uuid = "#{Settings.org_info.prefix}-#{self.id}"
      self.origin_url = Settings.org_info.url
      self.save!
    elsif self.uuid == nil
      self.uuid = "#{Settings.org_info.prefix}-#{self.id}"
      self.save!
    elsif self.origin_url == nil
      self.origin_url = Settings.org_info.url
      self.save!
    end
  end
end
