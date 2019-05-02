 json.ok true
 json.data do |json|
   json.id @album.id
   json.title @album.title
   json.slug @album.slug
   json.count @album.illustrations.count
   json.story do |json|
     json.id @album.story.id
     json.slug story_slug(@album.story)
     json.title @album.story.title
   end
   json.illustrators do |json|
     json.partial! 'api/v1/users/author', collection: @album.users, as: :author
   end
   json.illustrations do |json|
     json.partial! 'api/v1/illustrations/illustration', collection: @album.illustrations, as: :illustration
   end
 end
