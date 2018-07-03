json.ok true
if session[:submitted_story_notice] == true
  json.meta do |json|
    json.contestStoryNotice true
  end
end
json.data do |json|
  json.id @profile_data[:id]
  json.email @profile_data[:email]
  json.first_name @profile_data[:first_name]
  json.last_name @profile_data[:last_name]
  json.name @profile_data[:name]
  json.role @profile_data[:role]
  json.roles @profile_data[:roles]
  json.organizationRoles @profile_data[:organizationRoles].split(',')
  json.isOrganisationMember @profile_data[:isOrganisationMember]
  json.hasHistory @profile_data["hasHistory"]
  json.isLoggedIn @profile_data["isLoggedIn"]
  json.locale @profile_data["locale"]
  json.homePopup @profile_data["homePopup"]
  json.popupsSeen @profile_data["popupsSeen"]
  json.offlineBookPopupSeen @profile_data["offlineBookPopupSeen"]
  json.languagePreferences @profile_data['language_preferences']
  json.readingLevels @profile_data['reading_levels']
  json.downloadLimitReached current_user && current_user.story_download_count >= 30 ? true :false
  if @organization.present?
    json.orgName @organization.organization_name
    json.country @organization.country
  end
  if !(@myList.nil?)
    json.bookshelf do |json|
      json.title @myList.title
      json.id @myList.id
      json.count @myList.stories.count
      json.likeCount @myList.likes.count
      json.readCount @myList.list_views.count
      json.canDelete @myList.can_delete
      if @myList.organization
        if(@myList.organization.organization_type == "Publisher")
          json.publisher do |json|
            json.name @myList.organization.organization_name
            json.id @myList.organization.id
            json.slug org_slug(@myList.organization)
            json.profileImage @myList.organization.logo.url
          end
        else
          json.organisation do |json|
            json.name @myList.organization.organization_name
            json.id @myList.organization.id
            json.slug org_slug(@myList.organization)
            json.profileImage @myList.organization.logo.url
          end
        end    
      end
      json.description @myList.description
      json.slug list_slug(@myList)
      json.books do |json|
        json.partial! 'api/v1/stories/list_story', collection: @myList.lists_stories, as: :list_story
      end
    end
  else 
    json.bookshelf nil
  end
end