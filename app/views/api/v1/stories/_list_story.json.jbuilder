story = Story.find(list_story.story_id)
json.title story.title
json.id story.id
json.language story.language.name
json.level story.reading_level
json.slug story_slug(story)
json.isAudio story.is_audio && (story.audio_status == "audio_published" || (current_user && current_user.content_manager?))
json.synopsis story.synopsis
json.usageInstructions do
  json.html (list_story.how_to_use && list_story.how_to_use.size > 0) ? simple_format(list_story.how_to_use) : nil
  json.txt list_story.how_to_use
end
json.coverImage do
  json.aspectRatio 224.0/224.0
  json.cropCoords story.get_cover_image_crop_coords
  json.sizes story.get_image_sizes
end
json.authors story.authors.all.each do |author|
    json.slug user_slug(author)
    json.name author.name
end
