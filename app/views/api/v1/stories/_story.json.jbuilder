json.title story.title
json.id story.id
json.language story.language.name
json.level story.reading_level
json.slug story_slug(story) 
json.coverImage do
  json.aspectRatio 224.0/224.0
  json.cropCoords story.get_cover_image_crop_coords
  json.sizes story.get_image_sizes
end
json.authors story.authors.all.each do |author|
    json.slug user_slug(author)
    json.name author.name
end
