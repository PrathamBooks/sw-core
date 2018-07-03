json.ok true
json.data do
  json.name @story.title
  json.id @story.id
  json.language @story.language.name
  json.level @story.reading_level
  json.slug story_slug(@story)
  json.status @story.status
  json.description @story.synopsis
  json.liked current_user ? (current_user.voted_for? @story) : false
  json.isTranslation @story.is_translated?
  json.isRelevelled @story.is_relevelled?
  json.readsCount @story.reads
  json.likesCount @story.likes
  json.readingListMembershipCount @lists.count
  json.copyrightNotice @story.attribution_text
  json.orientation @story.orientation
  json.recommended @story.recommended_status =="recommended" || @story.recommended_status=="home_recommended"
  json.editorsPick @story.editor_recommended
  json.canEdit current_user ? policy(@story).editable? : false
  json.isFlagged current_user ? @story.flag_status(current_user) : false
  json.availableForOfflineMode @story.illustrations_available_for_offline?
  if (@story.contest.present? && @story.status == "submitted")
    json.isContestStory true
    json.showOptions current_user.content_manager? ? true : false
  end
  json.publisher do |json|
    json.slug get_publisher_slug(@story)
    json.name @story.organization.nil? ? "StoryWeaver Community" : @story.organization.organization_name
    json.website @story.organization.nil? ? nil : @story.organization.website
    json.logo organization_logo(@story)
  end
  json.publishedTime "#{@story.published_at.to_i * 1000}"
  json.donorName do |json|
    json.name @story.donor_id.nil? ? nil : @story.donor.name
  end
  if (!@story.contest_id.nil?)
    json.contest do |json|
      json.name @story.contest.name
      json.slug @story.contest.to_param
      json.won @story.winner.present?
    end
  else
    json.contest nil
  end
  json.similarBooks @similar_stories
  json.versionCount @story_other_version.count
  json.languageCount @uniq_languages
  if(@story.phone_story)
    json.externalLink do |json|
     json.text I18n.t("phone_story."+@story.phone_story.text)
     json.link @story.phone_story.link
   end
  else
    json.externalLink nil
  end
  json.translations @story_other_version.each do |t|
    json.title t.title
    json.id t.id
    json.slug story_slug(t)
    json.language t.language.name
    json.level t.reading_level
  end
  json.coverImage do |json|
     json.aspectRatio 224.0/224.0
     json.cropCoords @story.get_cover_image_crop_coords
     json.sizes @story.get_image_sizes
  end
  json.tags @story.tag_list.each do |tag|
    json.name tag
    json.query URI.encode(tag)
  end
  json.downloadLinks ["PDF", "epub", "HiRes PDF"].each_with_index do |type|
    if current_user ? policy(@story).download_type?(type) : false
      json.type type
      json.href get_download_link(@story, type)
    end
  end
  json.downloadLimitReached current_user && current_user.story_download_count >= 30 ? true :false
  json.googleFormDownloadLink "https://docs.google.com/forms/d/e/1FAIpQLSemX06BAWeaIOBR_wmjwNCHQHz16EqVq6VCYPAGTVTQacbA6A/viewform"
  json.authors @story.authors.each do |a|
    json.name a.name
    json.id a.id
    json.slug user_slug(a)
  end
  json.originalStory do
    json.name @story.root.title
    json.id @story.root.id
    json.slug story_slug(@story.root)
    json.authors @story.root.authors.each do |a|
      json.name a.name
      json.id a.id
      json.slug user_slug(a)
    end
  end
  json.illustrators @story.illustrators.each do |i|
    json.name i.user.name
    json.id i.user.id
    json.slug user_slug(i.user)
  end
  json.photographers @story.photographers.each do |user|
    json.name user.name
    json.id user.id
    json.slug user_slug(user)
  end
  json.lists @lists.each do |l|
    json.slug l.slug
    json.title l.title
  end
end

