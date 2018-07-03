# == Schema Information
#
# Table name: people
#
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  created_at              :datetime
#  updated_at              :datetime
#  created_by_publisher_id :integer
#  first_name              :string(255)
#  last_name               :string(255)
#  origin_url              :string(255)
#  uuid                    :string(255)
#
# Indexes
#
#  index_people_on_created_by_publisher_id  (created_by_publisher_id)
#

class Person < ActiveRecord::Base
 # attr_accessor :email , :bio
  validates :first_name, presence: true, length: {minimum: 2, maximum: 255}
  validates :email, presence: true, :email => true	, :if => :has_account?
  validates :bio, length: {maximum: 512}
  belongs_to :user
  after_create :add_uuid_and_origin_url

  has_and_belongs_to_many :illustrations,
    class_name: 'Illustration', join_table: 'illustrators_illustrations'

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

  def has_account?
    !user.nil?
  end

  def email
    user.try(:email)
  end

  def bio
    user.try(:bio)
  end

  def name
    if last_name.nil? || last_name.strip.empty?
      first_name
    else
      first_name + " " + last_name
    end
  end
end
