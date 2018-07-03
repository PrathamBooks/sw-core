# == Schema Information
#
# Table name: blog_posts
#
#  id                           :integer          not null, primary key
#  title                        :string(255)
#  body                         :text
#  status                       :integer
#  scheduled                    :datetime
#  comments_count               :integer          default(0)
#  user_id                      :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  published_at                 :datetime
#  reads                        :integer          default(0)
#  blog_post_image_file_name    :string(255)
#  blog_post_image_content_type :string(255)
#  blog_post_image_file_size    :integer
#  blog_post_image_updated_at   :datetime
#
# Indexes
#
#  index_blog_posts_on_user_id  (user_id)
#

class BlogPost < ActiveRecord::Base
  include Shared
  acts_as_taggable
  has_attached_file :blog_post_image,
  styles: {
    :size_1 => "320x",
    :size_2 => "480x",
    :size_3 => "640x",
    :size_4 => "800x",
    :size_5 => "960x",
    :size_6 => "1120x",
    :size_7 => "1280x"
    },
  default_url: "/assets/:style/missing.png",
  storage: Settings.blog_post_image.storage,
  fog_credentials: "#{Rails.root}/config/fog.yml",
  fog_directory: (Settings.fog.directory rescue nil),
  fog_host: (Settings.fog.host rescue nil),
  path: Settings.fog.blog_post_image_path
  searchkick callbacks: :async,
    searchable: [:title, :tags_name],
    merge_mappings: true

  validates_presence_of :title
  #validates_attachment_content_type :blog_post_image,  :content_type => ["image/svg+xml","image/jpg", "image/jpeg", "image/png", "image/gif"]
  #validates :blog_post_image , :presence => true
  has_many :comments
  belongs_to :user
  has_many :media_mentions

  after_create :scheduled_to_publish
  after_update :scheduled_to_publish

  STATUSES=[:draft, :published, :scheduled, :de_activated]
  enum status: STATUSES

  def search_data()
    {
      id: id,
      title: title,
      body: body,
      status: status,
      tags_name: tags.map(&:name),
      blogger: user.name,
      url_slug: to_param,
      comments_count: comments_count,
      updated_at: updated_at,
      created_at: created_at,
      published_at: published_at,
      archive: created_at.strftime("%Y-%B")
    }
  end

  scope :next, lambda {|id| where("status = ? and id > ?", BlogPost.statuses[:published], id).order("id ASC") } # this is the default ordering for AR
  scope :previous, lambda {|id| where("status = ? and id < ?", BlogPost.statuses[:published], id).order("id DESC") }

  def next
    BlogPost.next(self.id).first
  end

  def previous
    BlogPost.previous(self.id).first
  end

  def publish
    self.status = BlogPost.statuses[:published]
    self.published_at = self.scheduled_utc
    self.save!
  end

  def scheduled_to_publish
    if self.status == "scheduled"
      if self.created_at > self.scheduled_utc
        publish
      else
        Delayed::Job.enqueue Jobs::PublishBlogPostJob.new(self.id), 0, self.scheduled_utc
      end
    end
  end

  def to_param
    url_slug(id, title)
  end

  def scheduled_utc
    scheduled - 5.hours - 30.minutes
  end

  def self.increment!(ids, attr_name)
    Shared.increment_read!(ids, self.table_name, attr_name, self.connection)
    BlogPost.where(id: ids).each{|post| post.reindex}
  end
end
