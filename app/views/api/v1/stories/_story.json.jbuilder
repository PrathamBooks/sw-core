json.title story.title
json.id story.id
json.language story.language.name
json.level story.reading_level
json.slug story_slug(story) 
json.coverImage do
  json.aspectRatio 224.0/224.0
  json.cropCoords get_cover_image_crop_coords(story)
  json.sizes [:size1, :size2, :size3, :size4, :size5, :size6, :size7].each do |size|
    json.height get_cover_image_height(story, size)
    json.width get_cover_image_width(story, size)
    json.url get_cover_image_url(story, size)
  end
end
json.authors story.authors.all.each do |author|
    json.slug user_slug(author)
    json.name author.name
end
