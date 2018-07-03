# == Schema Information
#
# Table name: organizations
#
#  id                   :integer          not null, primary key
#  organization_name    :string(255)
#  organization_type    :string(255)
#  country              :string(255)
#  city                 :string(255)
#  number_of_classrooms :integer
#  children_impacted    :integer
#  status               :string(255)
#  logo_file_name       :string(255)
#  logo_content_type    :string(255)
#  logo_file_size       :integer
#  logo_updated_at      :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  description          :string(1000)
#  email                :string(255)
#  website              :string(255)
#  facebook_url         :string(255)
#  rss_url              :string(255)
#  twitter_url          :string(255)
#  youtube_url          :string(255)
#
# Indexes
#
#  index_organizations_on_email  (email)
#

class Organization < ActiveRecord::Base

  searchkick callbacks: :async,match: :word_start,
    searchable: [:organization_name],
    merge_mappings: true
	has_attached_file :logo,
  default_url: "/assets/:style/missing.png",
  storage: Settings.logo.storage,
  fog_credentials: "#{Rails.root}/config/fog.yml",
  fog_directory: (Settings.fog.directory rescue nil),
  fog_host: (Settings.fog.host rescue nil),
  path: Settings.fog.logo_path
  
  validates_attachment_content_type :logo,  :content_type => ["image/svg+xml","image/jpg", "image/jpeg", "image/png", "image/gif"]
  #validates :logo , :presence => true
  validates :organization_name, presence: true
  #validates :organization_type, presence: true
  validates :country, presence: true
  validates :number_of_classrooms, presence: true
  validates :children_impacted, presence: true
  #validates :status, presence: true
  translates :organization_name, :translated_name
  has_many :users
  has_many :stories
  has_many :lists
  has_many :illustrations
  has_many :media_mentions
  scope :original_story_publishers, -> { where(organization_type: "Publisher").joins(:stories).where('stories.status' => 1, 'stories.derivation_type' => nil).uniq.order(:organization_name) }
  scope :story_publishers, -> { where(organization_type: "Publisher").joins(:stories).where('stories.status' => 1).uniq.order(:organization_name) }

  after_create :add_uuid_and_origin_url



  def search_data()
    {
      id: id,
      organization_name: organization_name,
      organization_type: organization_type,
      slug: slug(),
      country: country,
      number_of_classrooms: number_of_classrooms,
      children_impacted: children_impacted,
      status: status,
      updated_at: updated_at,
      created_at: created_at,
      logo: logo.url,
      stories_count: stories_count(),
      lists_count: lists_count(),
      media_count: media_mentions_count()
    }
  end

  def stories_count()
    stories.where(status: Story.statuses[:published]).count
  end

  def lists_count()
    lists.where(status: List.statuses["published"]).count
  end

  def media_mentions_count()
    media_mentions.count
  end

  def slug()
    "#{self.id}-#{self.organization_name.parameterize}"
  end

  def has_recommended_right?
    true
  end

  def publisher?
    organization_type=="Publisher"
  end

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
