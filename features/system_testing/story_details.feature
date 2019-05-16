Feature: Story Details Page
Background:
  When I create "1" stories with category "Biographies" and language as "English" with reading_level "3" from the author as "pratham" with the title "Mockstory" and the flaggings_count as "0" and with org "admin@example.com"
  When I create "1" stories with category "Biographies" and language as "English" with reading_level "3" from the author as "pratham" with the title "Handmade in india" and the flaggings_count as "0" and with org "admin@example.com"
  When I create "1" stories with category "Biographies" and language as "English" with reading_level "3" from the author as "pratham" with the title "Asura and boy" and the flaggings_count as "4" and with org "admin@example.com"
  When I create "1" stories with category "Biographies" and language as "English" with reading_level "3" from the author as "pratham" with the title "The boat ride" and the flaggings_count as "4" and with org "admin@example.com"
  When I create "1" stories with category "Biographies" and language as "English" with reading_level "3" from the author as "pratham" with the title "glassdoor" and the flaggings_count as "4" and with org "admin@example.com"
  When I create "1" stories with category "Biographies" and language as "English" with reading_level "3" from the author as "pratham" with the title "samplestory" and the flaggings_count as "4" and with org "admin@example.com"

Scenario: To Validate the story card details
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  Then I click on first story
  Then I should be navigated to story details page

Scenario: To Validate the story card details from quick view details(quick view -> View details)
  Given I login to StoryWeaver with
    |Email    | user@sample.com        |
    |Password | password               |
  When I navigate to Read Page
  And I choose first story in read page
  Then I navigate to story details of first story
  When I select "View details" from quick view popup
  Then I should be navigated to story details page

Scenario: To Validate like a story from storydetails page with login
  Given I login to StoryWeaver with
    |Email    | user@sample.com        |
    |Password | password               |
  When I navigate to Read Page
  And I choose first story in read page
  When I navigate to story details of first story
  When I select "View details" from quick view popup
  And I should be navigated to story details page
  Then I get like count of that story
  And I like a story in storydetails page 
  Then I validate like count "should" incremented in storydetails page

Scenario: To Validate like a story from storydetails page without login
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  When I navigate to story details of first story
  When I select "View details" from quick view popup
  And I like a story in storydetails page
  Then I should see Log In and signup popup

Scenario: To Validate ADD TO MY BOOKSHELF from storydetails page
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to Read Page
  And I choose first story in read page
  When I navigate to story details of first story
  When I select "View details" from quick view popup
  And I choose "Add to My Bookshelf" from storydetails page
  Then I should see "Delete from My Bookshelf" in story details page

Scenario: To Validate ADD TO MY BOOKSHELF from storydetails page without login
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  And I click on first story
  Then I should be navigated to story details page
  And I choose "Add to My Bookshelf" from storydetails page
  Then I should see Log In and signup popup

Scenario: To Validate DOWNLOAD from storydetails page without login
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  Then I click on first story
  Then I should be navigated to story details page
  And I choose "Download" from storydetails page
  Then I should see Log In and signup popup

Scenario: To Validate TRANSLATE from storydetails page without login
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  Then I click on first story
  Then I should be navigated to story details page
  And I choose "Translate" from storydetails page
  Then I should see Log In and signup popup

Scenario: To Validate TRANSLATE from storydetails page with login
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to Read Page
  And I choose first story in read page
  Then I click on first story
  Then I should be navigated to story details page
  And I choose "Translate" from storydetails page
  Then I should navigated to translator editor page

Scenario: To Validate REPORT from storydetails page without login
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  Then I click on first story
  Then I should be navigated to story details page
  And I choose "Report" from storydetails page
  Then I should see Log In and signup popup

Scenario: To Validate MORE from storydetails page without login
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  Then I click on first story
  Then I should be navigated to story details page
  And I choose "More" from storydetails page
  Then I should see more actions popup on storydetails page

 Scenario: To Validate MORE from storydetails page with login for content manger
  Given I login to StoryWeaver with
    |Email    | content_manager@sample.com   |
    |Password | content_manager              |
  When I navigate to Read Page
  And I choose first story in read page
  Then I click on first story
  Then I should be navigated to story details page
  And I choose "More" from storydetails page
  Then I validate the fields present in more popup for content manager

Scenario: To Validate MORE from storydetails page with login for Normal user
  Given I login to StoryWeaver with
    |Email    | test@sample.com             |
    |Password | password                    |
  When I navigate to Read Page
  And I choose first story in read page
  Then I click on first story
  Then I should be navigated to story details page
  And I choose "More" from storydetails page
  Then I validate the fields present in more popup for normal user
  
Scenario: To Validate SHARE from storydetails page without login
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  Then I click on first story
  Then I should be navigated to story details page
  And I choose "Share" from storydetails page
  Then I should see share options on storydetails page

Scenario: To Validate read story from storydetails page
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  When I click on first story
  Then I should be navigated to story details page
  And I read a story from story_details page
  Then I should see story reader popup
  And I read the complete story

Scenario: To Validate smiley rating from read story popup with login
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to Read Page
  And I choose first story in read page
  When I click on first story
  Then I should be navigated to story details page
  And I get like count of that story
  And I read a story from story_details page
  Then I should see story reader popup
  And I read the complete story with smiley rating "like"
  Then I validate like count "should" incremented in storydetails page

Scenario: To Validate next read suggestions from read story popup with login
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to Read Page
  And I choose first story in read page
  When I click on first story
  Then I should be navigated to story details page
  And I get like count of that story
  And I read a story from story_details page
  Then I should see story reader popup
  Then I choose "glassdoor" a story from nextread suggestions
  Then I should see story reader popup
  And I read the complete story

Scenario: To Validate smiley rating from read story popup without login
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  When I click on first story
  Then I should be navigated to story details page
  And I get like count of that story
  And I read a story from story_details page
  Then I should see story reader popup
  And I read the complete story with smiley rating "okay"
  Then I validate like count "shouldn't" incremented in storydetails page

 Scenario: To Validate read views count from storydetails page
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to Read Page
  And I choose first story in read page
  When I click on first story
  Then I should be navigated to story details page
  And I get read count of that story
  And I read a story from story_details page
  Then I should see story reader popup
  And I read the complete story
  Then I validate story count "should" incremented in storydetails

Scenario: To Validate REPORT from storydetails page with login
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to Read Page
  And I choose first story in read page
  Then I click on first story
  Then I should be navigated to story details page
  And I choose "Report" from storydetails page
  Then I reported story with "This story is not an original creation." following reason
  Then I should see "Reported" in story details page

Scenario: To Validate next read suggestions and smiley rating from read story popup without login
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  When I click on first story
  Then I should be navigated to story details page
  And I get like count of that story
  And I read a story from story_details page
  Then I should see story reader popup
  Then I choose "glassdoor" a story from nextread suggestions
  Then I should see story reader popup
  And I read the complete story
# ---Need to take sperately to handle Save to offline functionality---

#Scenario: To Validate SAVE TO OFFLINE from storydetails page
#  Given I login to StoryWeaver with
#    |Email    | user@sample.com        |
#    |Password | password               |
#  When I navigate to Read Page
#  And I choose first story in read page
#  When I navigate to story details of first story
#  When I select "View details" from quick view popup
#  And I choose "Save to offline library" from storydetails page
#  Then I should see "Delete from offline library" in story details page