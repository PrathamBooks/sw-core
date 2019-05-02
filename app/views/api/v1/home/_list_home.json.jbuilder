json.title list.title
json.id list.id
json.count list.stories.count
json.liked current_user ? list.likes.include?(current_user) : false
json.readCount list.list_views.count
json.canDelete list.can_delete
json.author do |json|
  json.name list.user.name
  json.id list.user.id
  json.slug user_slug(list.user)
  json.profileImage list.user.profile_image.url
end
if list.organization
  if(list.organization.organization_type == "Publisher")
    json.publisher do |json|
      json.name list.organization.organization_name
      json.id list.organization.id
      json.slug org_slug(list.organization)
      json.profileImage list.organization.logo.url
    end
  else
    json.organisation do |json|
      json.name list.organization.organization_name
      json.id list.organization.id
      json.slug org_slug(list.organization)
      json.profileImage list.organization.logo.url
    end
  end    
end
json.description list.description
json.slug list_slug(list)
json.books do |json|
  json.partial! 'api/v1/stories/list_story', collection: list.lists_stories, as: :list_story
end
