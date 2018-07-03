json.id blog_post.id
json.title blog_post.title
json.imageUrls do |json|
  json.aspectRatio 464.0/261.0
  json.sizes [:size_1, :size_2, :size_3, :size_4, :size_5, :size_6, :size_7].each do |size|
    json.width get_blog_post_image_width(size)
    json.url blog_post.blog_post_image.url(size)
  end
end
json.blogUrl "#{host_url}/v0/blog_posts/#{blog_post.id}"
json.description get_description(blog_post)	 