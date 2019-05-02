Feature: Read Along Page
Background: 
  When I create one story with title "Story Weaver Test Automation" with lanuguage "English", with category "Type" as "Readalong", with reading level "1", with author email as "user@sample.com", with status as "published" 

Scenario: To Validate user should be navigated to read along page
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to Readalong Page
  Then I should be Readalong Page

Scenario: To Validate user is able to see readAlong icon on story card
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to Readalong Page
  And I choose first story in readalong page
  And I get available story options for the story
  Then I should see ReadAlong is available for the story card on hover over story

Scenario: To Validate user is able to see readAlong in story details page
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to Readalong Page
  And I choose first story in readalong page
  Then I click on first story in readalong page
  And I should see ReadAlong option along with Read

Scenario: To Validate user is able to see readAlong on more icons of story card
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to Readalong Page
  And I choose first story in readalong page
  Then I choose "Readalong" from quick view in read along page

Scenario: To Validate readalong filter is auto applied on navigating to readAlong page
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to Readalong Page
  Then I should see "Readalong" Filters in applied section of readalong page
