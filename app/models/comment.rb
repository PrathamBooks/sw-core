# == Schema Information
#
# Table name: comments
#
#  id           :integer          not null, primary key
#  blog_post_id :integer
#  body         :text
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_comments_on_blog_post_id  (blog_post_id)
#

class Comment < ActiveRecord::Base
  belongs_to :blog_post, :counter_cache => true
  belongs_to :user

  after_create :reindex_blog_post
  after_destroy :reindex_blog_post
  after_update :reindex_blog_post

  validates_presence_of :body

  def reindex_blog_post
    blog_post.reindex
  end
end
