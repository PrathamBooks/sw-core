json.ok true
json.data do
  json.name @story.title
  json.id @story.id
  json.language @story.language
  json.level @story.reading_level
  json.slug story_slug(@story)
  json.status @story.status
  json.description @story.synopsis
  json.similarBooks @similar_stories.first(Settings.per_page.entity_count)
end

