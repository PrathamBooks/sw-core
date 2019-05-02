Feature: Profile DashBoard

Scenario: To Validate organization name is not available for Normal user
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  And I select Profile from UserDashBoard
  Then I should not see any organization name under user section

Scenario: To Validate organization name is available for Organization user
  Given I login to StoryWeaver with
    |Email    | content_manager@sample.com  |
    |Password | content_manager             |
  And I select Profile from UserDashBoard
  Then I should see organization name as "Test Organization" under user section

Scenario: To Validate organization name is not available for normal user
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  And I select Profile from UserDashBoard
  Then I should see organization name as "" under user section

Scenario: To Validate the Stories created by user are getting added under stories tab in profile dash board
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add images to the story
  And I publish the story
  And I select Profile from UserDashBoard
  And I select 'stories' tab in Profile dashboard
  Then I should see newly created story in the list

Scenario: To Validate Stories are getting to user bookshelf
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Read Page
  And I choose first story in read page
  Then I choose "Add to My Bookshelf" from quick view
  When I select Profile from UserDashBoard
  And I select bookshelf tab in profile dashboard
  Then I should see the story added to my bookshelf

Scenario: To Validate Stories are removed to user bookshelf
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Read Page
  And I choose first story in read page
  Then I choose "Add to My Bookshelf" from quick view
  When I navigate to Read Page
  And I choose first story in read page
  Then I choose "Delete from My Bookshelf" from quick view
  When I select Profile from UserDashBoard
  And I select bookshelf tab in profile dashboard
  Then I shouldnot see the story added to my bookshelf

Scenario: To Validate, Illustrations are getting added under illustration tab in profile dash board
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
#pending

