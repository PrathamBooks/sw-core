Feature: Translate Story

@publish
@javascript
Scenario: Translate a story and publish
  When I create "1" stories with "Fantasy" and "English" and "2" by "user@sample.com" with "test translate english story" and "0" and with org "test_org@gmail.com"
  Given I stub auto_translate_api
  When I create translation of english stories
  When I login as "content_manager@sample.com" with "content_manager"
  When I click at "Content Manager"

  Then I click link "Translation Dashboard"
  When I click at "Translators"
  And I wait 10 seconds
  When I press "Select Language"
  And I fill in "Spanish" for ".input-block-level.form-control"
  Then I should see "Spanish"
  When I click at "Spanish"
  Then I fill in "language[email]" with "user@sample.com"
  And I press "Add Translator"
  Then I should see "Spanish" from "translator_details"
  #Then I check my mail for assigned as "Spanish" translator email --will activate this step once code is stabilized
  When I click at "Content Manager"
  When I click link "Sign Out"
  Then I expect "Log In"

  When I login again as "user@sample.com" with "password"
  And I wait 5 seconds
  And I click at "Common Man"
  When I click "Translate a Story"
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
  When I select option from "review_book_covers" as "publish"
  And I wait 20 seconds
  #Then I should see "Wohooo! Your story will appear on the New Arrivals in a short while." --will activate this step once code is stabilized
  Then I click at "Common Man"
  And I click link "Sign Out"

#validate translated story is displaying in Translated Stories
  When I login again as "content_manager@sample.com" with "content_manager"
  When I click at "Content Manager"
  When I click link "Translation Dashboard"
  And I wait 20 seconds
  And I refresh the page
  When I click at "Translated Stories"
  Then I should see "test translate english story"

@published_stories
@javascript
Scenario: Validate translated story present in mypublished stories
  When I create "1" stories with "Fantasy" and "English" and "2" by "user@sample.com" with "test translate english story" and "0" and with org "test_org@gmail.com"
  Given I stub auto_translate_api
  When I create translation of english stories
  When I login as "content_manager@sample.com" with "content_manager"
  When I click at "Content Manager"

  When I click link "Translation Dashboard"
  When I click at "Translators"
  And I wait 10 seconds
  When I press "Select Language"
  When I fill in "Spanish" for ".input-block-level.form-control"
  When I click at "Spanish"
  When I fill in "language[email]" with "user@sample.com"
  And I press "Add Translator"
  When I click at "Content Manager"
  When I click link "Sign Out"
  And  I wait 5 seconds
  When I login again as "user@sample.com" with "password"
  When I click at "Common Man"
  When I click link "Translate a Story"
  When I select option from "get_translator_language_stories" as "All Languages"
  And I wait 10 seconds
  And I click "Spanish"
  And I wait 5 seconds
  When I select option from "get_translator_language_stories" as "All Reading Levels"
  And I wait 5 seconds
  Then I click "Level 3"
  And I select "Translate Now"
  And I wait 20 seconds
  And I click "Exit"
  And I select "publish"
  And I wait 20 seconds
  Then I expect "STORY TITLE In the language of the story"
  When I fill in "story[title]" with "Test spanish translate story"
  When I fill in "story[english_title]" with "test spanish title"
  When I fill in "story[tag_list]" with "Test tag"
  And I select "next"
  And I wait 10 seconds
  When I select option from "review_book_covers" as "publish"
  And I wait 20 seconds
  #Then I should see "Wohooo! Your story will appear on the New Arrivals in a short while." --will activate this step once code is stabilized
  When I click at "Common Man"
  When I click link "Dashboard"
  When I click at "My Published Stories"
  Then I should see "test translate english story"

#@preview_save
@javascript
Scenario: Translate a story, preview and save
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
  When I click at "Spanish"
  When I fill in "language[email]" with "user@sample.com"
  And I press "Add Translator"
  When I click at "Content Manager"
  When I click link "Sign Out"
  When I login again as "user@sample.com" with "password"
  When I click at "Common Man"
  When I click link "Translate a Story"
  When I select option from "get_translator_language_stories" as "All Languages"
  And I wait 10 seconds
  And I click "Spanish"
  And I wait 5 seconds
  When I select option from "get_translator_language_stories" as "All Reading Levels"
  And I wait 5 seconds
  Then I click "Level 3"
  And I select "Translate Now"
  And I wait 15 seconds
  And I select "preview"
  And I wait 20 seconds
  And I should see "Author"
  When I click on "#close-button"
  And I select "Save"
  And I wait 5 seconds
  Then I should see "Editor’s Picks"
  #Then I should see "Your story has been saved as a draft. You can edit, complete and publish your story by clicking on 'My Drafts' on your profile page." --will activate this step once code is stabilized
  
#@save_continue
@javascript
Scenario: Validate translate a story - save and continue
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
  When I click at "Spanish"
  When I fill in "language[email]" with "user@sample.com"
  And I press "Add Translator"
  When I click at "Content Manager"
  When I click link "Sign Out"

  When I login again as "user@sample.com" with "password"
  When I click at "Common Man"
  When I click link "Translate a Story"
  When I select option from "get_translator_language_stories" as "All Languages"
  And I wait 10 seconds
  And I click "Spanish"
  And I wait 5 seconds
  When I select option from "get_translator_language_stories" as "All Reading Levels"
  And I wait 5 seconds
  Then I click "Level 3"
  And I select "Translate Now"
  And I wait 5 seconds
  When I click button "Translate Story" for "edit_story_3"
  And I click "Exit"

  And I select "publish"
  And I wait 20 seconds
  When I fill in "story[title]" with "Test spanish translate story"
  When I fill in "story[english_title]" with "test spanish title"
  When I fill in "story[tag_list]" with "Test tag"
  And I select "next"
  When I click on "review_book_covers" containing "save and publish later"
  And I wait 20 seconds
  #Then I should see "Your story has been saved as a draft. You can edit, complete and publish your story by clicking on 'My Drafts' on your profile page." --will activate this step once code is stabilized

  When I click at "Common Man"
  When I click link "Dashboard"
  When I click at "My Drafts"
  Then I should see "test translate english story"
  When I click at "Common Man"
  When I click link "Sign Out"
  
  When I login again as "content_manager@sample.com" with "content_manager"
  When I click at "Content Manager"
  When I click link "Translation Dashboard"
  When I click at "Translation Drafts"
  When I wait 10 seconds
  Then I should see in translation drafts as "Test spanish translate story"
  Then I should see in translation drafts as "Spanish"
  Then I should see in translation drafts as "user@sample.com"

@javascript
Scenario: Validate translate story mandatory fields and links
  When I create "1" stories with "Fantasy" and "English" and "2" by "user@sample.com" with "test translate english story" and "0" and with org "test_org@gmail.com"
  Given I stub auto_translate_api
  When I create translation of english stories

  When I login as "content_manager@sample.com" with "content_manager"
  When I click at "Content Manager"
  When I click link "Translation Dashboard"
  When I click at "Translators"
  When I wait 10 seconds

#Validate language cannot be blank
  When I fill in "language[email]" with "user@sample.com"
  And I press "Add Translator"
  Then I should see "language can't be blank"

#Validate email cannot be blank
  When I press "Select Language"
  When I fill in "Spanish" for ".input-block-level.form-control"
  When I click at "Spanish"
  When I fill in "language[email]" with ""
  And I press "Add Translator"
  Then I should see "email can't be blank"

#Validate email id is valid or not
  When I press "Select Language"
  When I fill in "Spanish" for ".input-block-level.form-control"
  When I click at "Spanish"
  When I fill in "language[email]" with "user@test"
  And I press "Add Translator"
  Then I should see "User does not exist"

#Validation for Translators Dropdown button
  When I press "Translators"
  Then I should see "Translators"
  When I click "Translators"
  Then I should see heading as "Translator" from "translator_details"
  And I wait 10 seconds

  When I press "Translators"
  And I should see "Languages"
  And I click "Languages"
  Then I should see heading as "Language" from "translator_details"
  When I press "Select Language"
  When I fill in "Spanish" for ".input-block-level.form-control"
  When I click at "Spanish"
  When I fill in "language[email]" with "user@sample.com"
  And I press "Add Translator"
  When I click at "Content Manager"
  Then I expect "Sign Out"
  When I click link "Sign Out"
  Then I expect "Log In"

  When I login again as "user@sample.com" with "password"
  When I click at "Common Man"
  When I click link "Translate a Story"
  When I click at "Stories to Translate"
  And I wait 10 seconds
  When I select option from "get_translator_language_stories" as "All Languages"
  And I wait 10 seconds
  Then I should see "Spanish"
  And I click "Spanish"
  And I wait 5 seconds
  When I select option from "get_translator_language_stories" as "All Reading Levels"
  And I wait 5 seconds
  Then I click "Level 3"
  And I select "Translate Now"
  And I wait 20 seconds
  And I select "publish"
  And I wait 30 seconds
  When I fill in "story[title]" with "Test spanish translate story"
  And I select "next"
  When I select option from "review_book_covers" as "publish"
  Then I should see "English title can't be blank"
  When I fill in "story[english_title]" with "test spanish title"
  When I fill in "story[tag_list]" with "Test tag"
  And I select "next"
  And I wait 10 seconds
  When I select option from "review_book_covers" as "publish"
  And I wait 20 seconds
  #Then I should see "Wohooo! Your story will appear on the New Arrivals in a short while." --will activate this step once code is stabilized
  When I click at "Common Man"
  When I click link "Sign Out"

  When I login again as "content_manager@sample.com" with "content_manager"
  When I click at "Content Manager"
  When I click link "Translation Dashboard"

#Validate the same story name should not display in "Stories to translate"
  When I click at "Stories to Translate"
  And I wait 10 seconds
  Then I should not see "Spanish"

@javascript
Scenario: Validate translate story should present in mydrafts of translator and user before saving
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
  When I click at "Spanish"
  When I fill in "language[email]" with "user@sample.com"
  And I press "Add Translator"
  When I click at "Content Manager"
  When I click link "Sign Out"

  When I login again as "user@sample.com" with "password"
  When I click at "Common Man"
  When I click link "Translate a Story"
  When I select option from "get_translator_language_stories" as "All Languages"
  And I wait 10 seconds
  And I click "Spanish"
  And I wait 5 seconds
  When I select option from "get_translator_language_stories" as "All Reading Levels"
  And I wait 5 seconds
  Then I click "Level 3"
  And I select "Translate Now"
  And I wait 5 seconds

#Validate story in Translated MyDrafts and in user My Drafts before clicking on Save
  When I click at "Common Man"
  When I click link "Dashboard"
  When I click at "My Drafts"
  ##Then I should see "test translate english story" --will activate this step once code is stabilized
  When I click at "Common Man"
  When I click link "Sign Out"

  When I login again as "content_manager@sample.com" with "content_manager"
  When I click at "Content Manager"
  When I click link "Translation Dashboard"
  When I click at "Translation Drafts"
  When I wait 10 seconds
  Then I should see in translation drafts as "Spanish"
  Then I should see in translation drafts as "user@sample.com"
