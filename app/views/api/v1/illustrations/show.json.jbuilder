json.ok true
json.data do
  json.title @illustration.name
  json.id @illustration.id
  json.slug illustration_slug(@illustration)
  json.datePublished @illustration.created_at.localtime.strftime("%d-%m-%Y")
  json.dateModified @illustration.updated_at.localtime.strftime("%d-%m-%Y")
  json.styles @styles.each do |style|
    json.name style
    json.query style
  end
  json.license_type @illustration.license_type
  json.attribution_text @illustration.attribution_text
  json.liked current_user ? (current_user.voted_for? @illustration) : false
  json.likesCount @illustration.likes
  json.readsCount @illustration.reads
  json.isPulledDown current_user.present? && current_user.content_manager? && @illustration.is_pulled_down?
  json.isFlagged current_user ? @illustration.flag_status(current_user) : false
  json.illustrationAccess true
  json.publisher do |json|
    json.slug get_image_publisher_slug(@illustration)
    json.name @illustration.organization.nil? ? "StoryWeaver Community" : @illustration.organization.organization_name
    json.website @illustration.organization.nil? ? nil : @illustration.organization.website
    json.logo image_organization_logo(@illustration)
  end
  json.imageUrls get_list(@illustration).each do |il|
    json.aspectRatio 320.0/240.0
    json.cropCoords get_image_crop_coords(il)
    json.sizes [:large, :search].each do |size|
      json.height get_image_height(il, size)
      json.width get_image_width(il, size)
      json.url get_image_url(il, size)
    end
  end
  json.illustrators do |json|
    json.partial! 'api/v1/users/author', collection: @illustrators, as: :author
  end
  json.similarillustrations do |json|
    json.partial! 'api/v1/illustrations/illustration', collection: @similar_illustrations, as: :illustration
  end
  json.downloadLinks @illustration.get_download_formats.each do |type|
    if current_user ? policy(@illustration).download_type?(type) : false
      json.type type
      json.href download_illustrations_url(@illustration, style: (type =~ /HiRes/) ? "original" : "large")
    end
  end
  json.downloadLimitReached current_user.present? && current_user.illustration_download_limit_reached?
  json.tags @illustration.tag_list.each do |tag|
    json.name tag
    json.query URI.encode(tag)
  end
  json.categories @categories.each do |category|
    json.name category.translated_name
    json.query category.name
  end
  json.usedIn do
    json.totalStories @illustration.number_of_parent_stories_used_in
    json.stories @illustration.parent_story_links.each do |story|
      json.title story.title
      json.slug story_slug(story)
      json.numDerivations story.get_children_count if story.get_children_count  > 0
    end
  end
end
