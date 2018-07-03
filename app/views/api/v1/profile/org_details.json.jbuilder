json.ok true
json.data do |json|
  json.type @org_type
  json.name @org.organization_name
  json.id @org.id
  json.description @org.description
  json.email @org.email
  json.website @org.website
  json.profileImage @org.logo.url
  json.slug org_slug(@org) 
  json.reading_lists do |json|
    json.meta @org_lists[:metadata]
    json.results @org_lists[:search_results]
  end
  json.mediaMentions do |json|
    json.meta @media_mentions_metadata
    json.results do |json|
      json.partial! 'api/v1/profile/mediaMentions', collection: @media_mentions, as: :mention
    end
  end
  json.socialMediaLinks do |json|
    json.facebookUrl @org.facebook_url
    json.rssUrl @org.rss_url
    json.twitterUrl @org.twitter_url
    json.youtubeUrl @org.youtube_url
  end
  if(@org_type == "PUBLISHER")
    json.newArrivals do |json| 
      json.meta @new_arrivals[:metadata]
      json.results @new_arrivals[:search_results]
    end
    json.editorsPick do |json|
      json.meta @editor_recommendations[:metadata]
      json.results @editor_recommendations[:search_results]
    end
  end
end
