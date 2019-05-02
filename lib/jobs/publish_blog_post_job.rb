class Jobs::PublishBlogPostJob < Struct.new(:post_id)
  def perform
    blog_post = BlogPost.find_by(id: post_id)
    if blog_post.nil?
      return
    else
      blog_post.publish
    end
  end
  def queue_name
    'blog_publish'
  end
end

