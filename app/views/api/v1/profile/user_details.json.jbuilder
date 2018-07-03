json.ok true
json.data do |json|
  json.slug user_slug(@user) 
  json.name @user.name
  json.description @user.bio
  json.email @user.email
  json.website @user.website
  json.profileImage @user.profile_image.url
  json.id @user.id
  json.books do |json|
    json.meta @user_stories[:metadata]
    json.results @user_stories[:search_results]
  end
  json.translations do |json|
    json.meta @user_translated_stories[:metadata]
    json.results @user_translated_stories[:search_results]
  end
  json.releveled_stories do |json|
    json.meta @user_relevelled_stories[:metadata]
    json.results @user_relevelled_stories[:search_results]
  end
  json.lists do |json|
    json.meta @user_lists[:metadata]
    json.results @user_lists[:search_results]
  end
  json.illustrations do |json|
    json.meta @illus_metadata
    json.results @user_illustrations
  end
  json.mediaMentions do |json|
    json.meta @media_mentions_metadata
    json.results do |json|
      json.partial! 'api/v1/profile/mediaMentions', collection: @media_mentions, as: :mention
    end
  end
  if @user_org
    json.organisation do |json|
      json.name @user_org.organization_name
      json.slug org_slug(@user_org)
      json.type @user_org_type
    end
  else
      json.organization nil
  end
  
end
