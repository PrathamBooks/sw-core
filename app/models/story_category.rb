# == Schema Information
#
# Table name: story_categories
#
#  id                               :integer          not null, primary key
#  name                             :string(32)       not null
#  created_at                       :datetime
#  updated_at                       :datetime
#  private                          :boolean          default(FALSE)
#  contest_id                       :integer
#  active_on_home                   :boolean          default(FALSE)
#  category_banner_file_name        :string(255)
#  category_banner_content_type     :string(255)
#  category_banner_file_size        :integer
#  category_banner_updated_at       :datetime
#  category_home_image_file_name    :string(255)
#  category_home_image_content_type :string(255)
#  category_home_image_file_size    :integer
#  category_home_image_updated_at   :datetime
#  t_name                           :string(255)
#  translated_name                  :string(255)
#  origin_url                       :string(255)
#  uuid                             :string(255)
#
# Indexes
#
#  index_story_categories_on_name  (name)
#

class StoryCategory < ActiveRecord::Base

  has_attached_file :category_banner,
  styles: {
  	:size_1 => "692x",
  	:size_2 => "1064x",
  	:size_3 => "1436x",
  	:size_4 => "1808x",
  	:size_5 => "2180x",
  	:size_6 => "2552x"
  	},
  default_url: "/assets/:style/missing.png",
  storage: Settings.category_banner.storage,
  fog_credentials: "#{Rails.root}/config/fog.yml",
  fog_directory: (Settings.fog.directory rescue nil),
  fog_host: (Settings.fog.host rescue nil),
  path: Settings.fog.category_banner_path

  validates_attachment_content_type :category_banner,  :content_type => ["image/svg+xml","image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_attached_file :category_home_image,
  styles: {
  	:size_1 => "240x",
  	:size_2 => "320x",
  	:size_3 => "480x",
  	:size_4 => "640x"
  	},
  default_url: "/assets/:style/missing.png",
  storage: Settings.category_home_image.storage,
  fog_credentials: "#{Rails.root}/config/fog.yml",
  fog_directory: (Settings.fog.directory rescue nil),
  fog_host: (Settings.fog.host rescue nil),
  path: Settings.fog.category_home_image_path

  validates_attachment_content_type :category_home_image,  :content_type => ["image/svg+xml","image/jpg", "image/jpeg", "image/png", "image/gif"]


  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 32 }

  translates :name, :translated_name

  default_scope {order("name ASC") }

  has_and_belongs_to_many :stories, class_name: 'Story'
  belongs_to :contest

  after_create :add_uuid_and_origin_url

  after_commit :reindex_stories

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

  def reindex_stories
    stories.each{|story| story.reindex}
  end

  def slug
    "#{id}-#{name.parameterize}"
  end
end
