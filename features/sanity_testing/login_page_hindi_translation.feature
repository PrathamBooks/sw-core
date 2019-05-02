Feature: Login to storyweaver page

@javascript
Scenario: Login to storyweaver page - valid email and password- with hindi translation
  When I create "1" stories with "Fantasy" and "English" and "2" by "user@sample.com" with "test translate english story" and "0" and with org "test_org@gmail.com"
  When I login as "user@sample.com" with "password" for hindi translation
  Then I expect "Common Man"
  Then I should not see invalid translation
  Then I click dots menu
  And I wait 5 seconds
  Then I should not see invalid translation
  When I select "मेरे बुकशेल्फ में जोड़ें"
  Then I should not see invalid translation
