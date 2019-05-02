json.ok true
json.data do
  json.levelBand level_band_image(@story)
  json.publisherLogo  organization_logo(@story)
  json.donorLogo @story.donor.nil? ? nil : @story.donor.logo.url(:original) 
  json.orientation @story.orientation
  json.language @story.language.name
  json.isAudio @story.is_audio
  json.isGif @story.is_gif? 
  json.audioStatus @story.audio_status
  if @story.is_audio
    json.audioPath @story.audio_path
    json.coverAudioPath @story.cover_audio_path
    json.vttFilePath @story.vtt_file_path 
  end
  if current_user
    json.hasSmileyRating current_user.has_smiley_rating(@story) ? true : false
  else
    json.hasSmileyRating @story.smiley_ratings.where(:session_id => session.id).present? ? true : false
  end
  json.isLanguageReviewer current_user && current_user.is_language_reviewer(@story.language.name)
  json.reviewStory current_user ? current_user.has_story_reviewed(@story) : false
  json.level @story.reading_level
  json.slug story_slug(@story)
  json.pages @story.pages.each do |p|
    json.pageId p.id
    json.pagePostion p.position
    json.pageType p.type
    json.isLastStoryPage p == @story.story_pages.last
    if p.illustration_crop
      json.coverImage do
        json.aspectRatio 224.0/224.0
        json.cropCoords p.illustration_crop.smart_crop_details.nil? ? {"x"=>0, "y" => 0} : p.illustration_crop.parsed_smart_crop_details 
        json.sizes [:size1, :size2, :size3, :size4, :size5, :size6, :size7].each do |size|
          json.height p.illustration_crop.image_geometry(size).height
          json.width p.illustration_crop.image_geometry(size).width
          json.url p.illustration_crop.url(size)
        end
      end
    end
    json.html render(:partial => "/pages/api_page", locals: {page: p}, formats: [:html])
  end
  json.css ActionController::Base.helpers.asset_path("api/reader.css")
end

