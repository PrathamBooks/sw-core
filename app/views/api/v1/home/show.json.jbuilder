json.ok true
json.data do |json|
  json.bannerImages do |json|
    json.partial! 'api/v1/home/banner', collection: @banner_images, as: :banner
  end
  json.editorsPick do |json|
    json.meta @editor_picks[:metadata]
    json.results @editor_picks[:search_results]
  end
  json.newArrivals do |json| 
    json.meta @new_arrivals[:metadata]
    json.results @new_arrivals[:search_results]
  end  
  json.mostRead do |json|
    json.meta @most_read[:metadata]
    json.results @most_read[:search_results]
  end
  json.blogPosts do |json|
    json.partial! 'api/v1/home/blog_post', collection: @blog_posts, as: :blog_post
  end
  json.lists @lists
  json.statistics do |json|
    json.storiesCount @stories_count
    json.readsCount @reads_count
    json.languagesCount @languages_count
  end
end
