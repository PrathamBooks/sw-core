Feature: Create flow of story

Background:
  When I create one illustration for "user@sample.com" with title "Test Image"

Scenario: To Validate Guest user will not be allowed to create story.
  Given I open StoryWeaver
  When I navigate to Create Page
  Then I should navigate to login page

Scenario: To Validate available options in Create Story popup.
	Given I login to StoryWeaver with
  |Email    | user@sample.com             |
  |Password | password                    |
  When I navigate to Create Page
  Then I should see create popup
  And I Validate the avaliable fields in the create story popup

Scenario: To Validate Cancel action navigates back to home page of the Story Weaver.
	Given I login to StoryWeaver with
	  |Email    | user@sample.com             |
	  |Password | password                    |
  When I navigate to Create Page
  Then I should see create popup
  When I choose cancel in create story popup
  Then I should navigate to Home Page successfully

Scenario: To Validate User should be able to create/publish a story.
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add images to the story
  And I publish the story

Scenario: To Validate "Save to Favourites".
	Given I login to StoryWeaver with
	  |Email    | user@sample.com             |
	  |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I open image drawer
  And I add the first image to my favourites
  And I close image drawer
  And I open image drawer
  Then I should see updated favourite list 

Scenario: To Validate "Remove from Favourites".
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I open image drawer
  And I add the first image to my favourites
  And I open image drawer
  Then I remove the image from my favourites
  And I close image drawer
  And I open image drawer
  Then I should see zero images in my favourite list

Scenario: To Validate User should be able to edit Book Information in the middle of create story
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I change the title of the story to "Automation Title" through edit book information
  Then I validate the updated title in story create page

Scenario: To Validate User should be able to add more pages as required
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I get the total no.of pages avaliable for the story
  And I add '3' pages to the story
  Then I Validate total pages got incremented by '3'

Scenario: To Validate User should be able to delete pages as required
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add '3' pages to the story
  And I get the total no.of pages avaliable for the story
  And I delete a page from the story
  Then I Validate total pages got decremented by '1'

Scenario: To Validate User cannt remove the last story page(excluding Front and Back cover)
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I delete the last page of the story
  Then I should see a delete validation popup

Scenario: To Validate User should is able to preview the story
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add '1' pages to the story
  And I add images to the story
  And I get the total no.of pages avaliable for the story
  Then I should be able to preview the story

Scenario: To Validate help in create page flow
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I click on help in create page
  Then I validate the platform navigates me through all the actions available in the create page

Scenario: To Validate Upload Image popup attributes for normal user login.
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I open image drawer
  Then I choose upload image
  Then I validate the fields present in editorupload popup for normal user

Scenario: To Validate Upload Image popup attributes for content manager login.
  Given I login to StoryWeaver with
    |Email    | content_manager@sample.com   |
    |Password | content_manager              |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I open image drawer
  Then I choose upload image
  Then I validate the fields present in editorupload popup for content manager

Scenario: To Validate User should be able to upload a image only after all the fields are filled.
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I open image drawer
  Then I choose upload image
  When I fill fields present in editorupload popup
  Then I uploaded an illustration

Scenario: To Validate Pulisher popup fields for normal user.
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add images to the story
  And I navigate to publish pop
  Then I validate the fields present in publish popup for normal user

Scenario: To Validate Pulisher popup fields for content manager.
  Given I login to StoryWeaver with
    |Email    | content_manager@sample.com  |
    |Password | content_manager             |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add images to the story
  And I navigate to publish pop
  Then I validate the fields present in publish popup for content manager

Scenario: To Validate Story will not be published if one/all the required fields in  publisher popup are not filled.
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add images to the story
  And I publish the story without title
  Then I should see error regarding title in publish popup

Scenario: To Validate user is able to create a story
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add images to the story
  And I get the title of the story
  And I publish the story
  Then I should be navigated to read page
  And I apply sort filter with "New Arrivals"
  And I validate newly created story is present first in read page