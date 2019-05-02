json.array!(@blog_posts) do |blog_post|
  json.extract! blog_post, :id, :title, :body, :status, :scheduled, :comments_count, :user_id
  json.url blog_post_url(blog_post, format: :json)
end
