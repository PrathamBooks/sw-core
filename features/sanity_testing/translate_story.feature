Feature: Translate Story

@javascript
Scenario: Translate a story and publish
  When I create "1" stories with "Fantasy" and "English" and "2" by "user@sample.com" with "test translate english story" and "0" and with org "test_org@gmail.com"
  Given I stub auto_translate_api
  When I create translation of english stories
  When I login as "content_manager@sample.com" with "content_manager"
  When I click at "Content Manager"

  When I click link "Translation Dashboard"
  When I click at "Translators"
  When I wait 10 seconds
  When I press "Select Language"
  When I fill in "Spanish" for ".input-block-level.form-control"
  Then I should see "Spanish"
  When I click at "Spanish"
  When I fill in "language[email]" with "user@sample.com"
  And I press "Add Translator"
  Then I should see "Spanish" from "translator_details"
  #Then I check my mail for assigned as "Spanish" translator email
  When I Sign Out
  When I click at "Content Manager"
  When I click link "Sign Out"
  When I wait 10 seconds
  Then I expect "Log In"
  When I login again as "user@sample.com" with "password"
  When I click at "Common Man"
  When I click link "Translate a Story"
  Then I should see "Stories to Translate"
  And I wait 5 seconds
  When I select option from "get_translator_language_stories" as "All Reading Levels"
  And I wait 5 seconds
  Then I click "Level 3"
  And I wait 15 seconds
  When I select option from "get_translator_language_stories" as "All Languages"
  And I wait 10 seconds
  And I click "Spanish"
  And I should see "Spanish" from "get_translator_language_stories"
  And I select "Translate Now"
  And I wait 20 seconds
  Then I should see "publish"
  Then I should see "save"
  And I click "Exit"
  And I select "publish"
  And I wait 20 seconds
  Then I expect "PUBLISH: :Complete and verify book details"
  When I fill in "story[title]" with "Test spanish translate story"
  When I fill in "story[english_title]" with "test spanish title"
  When I fill in "story[tag_list]" with "Test tag"
  And I select "next"
  And I wait 10 seconds
  #When I select option from "review_book_covers" as "publish"
  #And I wait 10 seconds
  #When I click on "redirect_home" containing "×"
  #And I wait 20 seconds
  #Then I should see "Wohooo! Your story will appear on the New Arrivals in a short while."
