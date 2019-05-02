json.ok true
json.data do |json|
  json.slug user_slug(@user) 
  json.name @user.name
  json.description @user.bio
  json.email @user.email
  json.website @user.website
  json.profileImage @user.profile_image
  json.id @user.id
end