# == Schema Information
#
# Table name: illustration_styles
#
#  id         :integer          not null, primary key
#  name       :string(32)       not null
#  created_at :datetime
#  updated_at :datetime
#  origin_url :string(255)
#  uuid       :string(255)
#

class IllustrationStyle < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true, length: {maximum: 32}
  default_scope {order("name ASC") }
  
  has_and_belongs_to_many :illustrations

  after_create :add_uuid_and_origin_url

  after_commit :reindex_illustrations
  
  translates :name, :translated_name

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

  def reindex_illustrations
    illustrations.each{|illustration| illustration.reindex}
  end
end
