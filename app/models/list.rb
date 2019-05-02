# == Schema Information
#
# Table name: lists
#
#  id              :integer          not null, primary key
#  title           :string(255)
#  description     :string(1000)
#  user_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer
#  status          :integer          default(0), not null
#  synopsis        :string(750)
#  can_delete      :boolean          default(TRUE)
#  is_default_list :boolean          default(FALSE)
#

class List < ActiveRecord::Base
  include ActionView::Helpers
  belongs_to :user
  belongs_to :organization
  has_many :list_likes
  has_many :likes, through: :list_likes, source: :user
  has_many :lists_stories , -> {order('position ASC')}
  has_many :stories, through: :lists_stories
  has_and_belongs_to_many :categories, class_name: "ListCategory"
  has_many :list_views
  has_many :list_downloads, dependent: :destroy

  STATUSES=[:draft, :published]
  enum status: STATUSES

  validates :title, presence: true , length: {maximum: 255}
  validates :user, presence: true
   
  scope :default_list, -> { where("is_default_list is true") }
  scope :without_default_list, -> { where("is_default_list is false")}

  searchkick callbacks: :async,
             batch_size: 100,
             searchable: [:title, :description, :status, :languages, :reading_levels, :author_id, :organization_id],
             filterable: [:title, :description, :status, :languages, :reading_levels, :author_id, :organization_id, :count, :categories],
             mappings: {
               story: {
                 properties: {
                   created_at: {type: "date"},
                   likes: {type: "long"},
                   views: {type: "long"},
                 }
               }
             },
             merge_mappings: true
  def search_data()
    {
      id: id,
      title: title,
      description: description,
      slug: slug,
      status: status,
      categories: categories.map(&:name),
      likes: likes.count,
      views: list_views.count,
      created_at: created_at,
      author: user.name,
      author_id: user.id,
      author_slug: user_slug(user),
      organization_name: organization ? organization.organization_name : nil  ,
      organization_id: organization ? organization.id : nil,
      organization_slug: organization ? org_slug(organization) : nil ,
      organization_profile_image: organization ? organization.logo.url : nil,
      organization_type: organization ? organization.organization_type : nil, 
      count: stories.count,
      books: stories_details,
      languages: stories.map{|s| s.language.name}.flatten.uniq,
      reading_levels: stories.map{|s| s.reading_level}.flatten.uniq,
      can_delete: can_delete,
      stories_tips: lists_stories.map{|ls| ls.how_to_use}
    }
  end

  def stories_details
    stories.map{|s| {:name=>s.title, :language => s.language.name, :level => s.reading_level, :coverImage => cover_image(s), :authors=>s.authors.map{|a| {:slug=> user_slug(a), :name=>a.name}}}}
  end

  def cover_image(story)
    {
      :aspectRatio => 224.0/224.0,
      :cropCoords => story.get_cover_image_crop_coords,
      :sizes => story.get_image_sizes
    }
  end

  def user_slug(user)
    "#{user.id}-#{user.name.parameterize}"
  end  
  def org_slug(org)
    "#{org.id}-#{org.organization_name.parameterize}"
  end 
  def slug
    "#{id}-#{title.parameterize}"
  end 

  def track_download(current_user, ip_address)
    download = ListDownload.new
    download.user = current_user
    download.list = self
    download.ip_address = ip_address
    download.when = DateTime.now
    download.save!
  end

end
