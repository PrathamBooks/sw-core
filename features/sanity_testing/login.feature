Feature: Login to storyweaver page

@javascript
Scenario: Login to storyweaver page - valid email and password
  When I login as "user@sample.com" with "password"
  Then I expect "Common Man"
  #Then I expect "Signed in successfully."

@javascript
Scenario: Login to storyweaver page - validate user profile
  When I login as "user@sample.com" with "password"
  When I click at "Common Man"
  When I click link "Profile"
  Then I expect "Stories (0)"

@javascript
Scenario: Login to storyweaver page - validate signout
  When I login as "user@sample.com" with "password"
  When I click at "Common Man"
  When I click link "Sign Out"
  And I wait 5 seconds
  Then I should not see "Common Man"
  #Then I expect "Signed out successfully."
