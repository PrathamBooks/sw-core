json.title mention.blog_post.title
json.id mention.id
json.date "#{mention.blog_post.published_at.to_i * 1000}"
json.platform "StoryWeaver Blog"
json.description get_description(mention.blog_post)
json.url "#{host_url}/blog_posts/#{mention.blog_post_id}"