Feature: Validate Read Record of the Stories

@javascript
Scenario: Read Story Count- with login
  Given I mock discourse
  When I create "2" stories with "Fantasy" and "English" and "2" by "user@sample.com" with "English story of Re-Levelled type" and "relevelled"
  When I login as "user@sample.com" with "password"
  When I click at "Read"
  When I wait 10 seconds
  Then I should see 2 stories
  When I click on ".pb-link.pb-link--default.pb-book-card__link"
  When I click "Read Story"
  When I wait 10 seconds
  And I should see story read count as "0"
  When I should see read completed as "false"
  When I click on icon "Next"
  And I wait 2 seconds
  When I click on icon "Next"
  And I wait 2 seconds
  When I click on icon "Next"
  And I wait 2 seconds
  When I click on icon "Close"
  #Then I should see read completed as "true"
  And I refresh the page
  And I wait 5 seconds
  Then I should see story read count as "1"

@javascript
Scenario: Read Story count - without login
  Given I mock discourse
  When I create "2" stories with "Fantasy" and "English" and "2" by "user@sample.com" with "English story of orginal type" and "nil"
  Given I am on the Home page
  When I click at "Read"
  When I wait 10 seconds
  Then I should see 2 stories
  When I click on ".pb-link.pb-link--default.pb-book-card__link"
  When I click "Read Story"
  When I wait 10 seconds
  And I should see story read count as "0"
  When I click on icon "Next"
  When I click on icon "Next"
  When I click on icon "Next"
  When I should see story records as "0"
  When I click on icon "Close"
  And I refresh the page
  And I wait 2 seconds
  Then I should see story read count as "1"
