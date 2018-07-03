Feature: Add Rating Resource

#@rateastory-original
@javascript
Scenario: Validate original story to rate and review
  
  When I create "1" stories with "Fantasy" and "English" and "2" by "user@sample.com" with "test reviewer story" and "2" and with "admin@prathambooks.org"
  When I create "2" stories with "Fantasy" and "English" and "2" by "user@sample.com" with "English story of orginal type" and "nil"

  When I login as "content_manager@sample.com" with "content_manager"
  When I click at "Content Manager"
  When I click link "Rating Dashboard"
  When I click at "Rating Resources"
  When I wait 10 seconds
  When I press "Select Language"
  When I fill in "English" for ".input-block-level.form-control"
  When I click at "English"
  When I fill in "language[email]" with "content_manager@sample.com"
  And I press "Add Rating Resource"
  #Then I check my mail for assigned as "English" reviewer email

  When I click at "Content Manager"
  When I click link "Rate a Story"
  Then I should see "Click on any of the titles below to START with rating a story."
  And I should see "English" from "get_reviewer_language_stories"
  When I select option from "get_reviewer_language_stories" as "All Languages"
  And I click "English"
  And I wait 5 seconds
  When I select option from "get_reviewer_language_stories" as "All Story Types"
  And I click "Original"
  And I wait 5 seconds
  When I select option from "get_reviewer_language_stories" as "All Reading Levels"
  Then I click "Level 3"
  And I wait 5 seconds
  And I should see "English" from "get_reviewer_language_stories"
  And I should see "Original" from "get_reviewer_language_stories"

  When I click on first story to rate
  And I wait 20 seconds
  And I click "Click here to start rating the story"
  And I wait 20 seconds
  Then I access the new tab
  And I wait 20 seconds
  Then I should see "Click on the image to read"
  And I should see review form as disabled

 #Flag a Story

  When I select checkbox "last_option1" contains value "Nothing to worry about!"
  When I select checkbox "last_option2" contains value "Nothing to worry about!"
  When I select checkbox "last_option3" contains value "Nothing to worry about!"
  Then I should see review form as enabled
  When I select radio button "reviewer_comment[story_rating]" contains value "reviewer_comment_story_rating_5"
  When I select radio button "reviewer_comment[language_rating]" contains value "reviewer_comment_language_rating_5"
  When I select rating star
  And I choose "Submit"
  And I wait 10 seconds
  And I press "No"
  And I wait 10 seconds
  Then I should see "Our community of readers will be able to find the very best stories on StoryWeaver, thanks to you."
  And I press "Not now!"
  Then I should see "Editor’s Picks"
