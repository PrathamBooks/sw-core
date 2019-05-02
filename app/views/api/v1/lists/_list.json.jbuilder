json.title list.title
json.id list.id
json.count list.stories.count
json.description list.description
json.slug list_slug(list)
json.canDelete list.can_delete
json.categories list.categories.map(&:name)
json.books do |json|
  json.partial! 'api/v1/stories/story', collection: list.stories.limit(4), as: :story
end
