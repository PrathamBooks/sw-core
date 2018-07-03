json.ok true
json.data do |json|
  json.org_type @org_type
  json.name @org.organization_name
  json.id @org.id
  json.description @org.description
  json.email @org.email
  json.website @org.website
  json.profileImage @org.profile_image
  json.slug org_slug(@org)
end