Feature: Homepage validation

@javascript
Scenario: Login as user to validate home page

  When I login as "user@sample.com" with "password"
  Then I expect "Signed in successfully."

  Then I should see "read"
  Then I should see "create"
  Then I should see "translate"
  Then I should see "about"

  #Then I should see carousel
  Then I should see "STORIES"
  Then I should see "READS"
  Then I should see "LANGUAGES"

  Then I should see "editor's picks"
  Then I should see "new arrivals"
  Then I should see "most read"
  Then I should see "most liked"

  Then I should see "StoryWeaver"
  Then I should see "FAQs"
  Then I should see "T&C"
  Then I should see "Contact"
  #Then I should see "Connect"

  Then I should see "open licensed content"
  Then I should see "privacy policy"
  Then I should see "pratham books"
  Then I should see "credits"

  Then I should see "Privacy Policy"
  Then I should see "Terms & Conditions"
  Then I should see "Pratham Books"
  Then I should see "All Rights Reserved."

  Then I should see "Except where otherwise noted, content on this site is licensed under a Creative Commons Attribution 4.0 License International (CC-BY-4.0)"
  Then I should see "follow us on"

@javascript
Scenario: Validate social icon facebook

  When I login as "user@sample.com" with "password"
  When I click on icon "facebook"
  And I access the new tab
  When I get the URL of current page
  Then I should see "Pratham Books' StoryWeaver"

@javascript
Scenario: Validate social icon twitter

  When I login as "user@sample.com" with "password"
  When I click on icon "twitter"
  And I access the new tab
  Then I should see "Tweets"

@javascript
Scenario: Validate social icon youtube

  When I login as "user@sample.com" with "password"
  When I click on icon "youtube-play"
  And I wait 10 seconds
  And I access the new tab
  When I wait 10 seconds
  Then I should see "Pratham Books StoryWeaver"

@javascript
Scenario: Validate social icon blog 
 
  When I login as "user@sample.com" with "password"
  When I click on icon "rss"
  And I access the new tab
  Then I should see "StoryWeaver is an open source digital platform from Pratham Books"

@javascript
Scenario: Validate social icon facebook in the side bar

  When I login as "user@sample.com" with "password"
  When I click on "facebook" icon in the side bar
  And I access the new tab
  Then I should see "Pratham Books' StoryWeaver"

@javascript
Scenario: Validate social icon twitter in the side bar

  When I login as "user@sample.com" with "password"
  When I click on "twitter" icon in the side bar
  And I access the new tab
  Then I should see "An open source platform for stories by @prathambooks. Read, play, remix!"

@javascript
Scenario: Validate social icon youtube in the side bar

  When I login as "user@sample.com" with "password"
  When I click on "youtube" icon in the side bar
  And I access the new tab
  Then I should see "Pratham Books StoryWeaver"

@javascript
Scenario: Validate social icon blog in the side bar

  When I login as "user@sample.com" with "password"
  When I click on "blog" icon in the side bar
  And I access the new tab
  Then I should see "StoryWeaver is an open source digital platform from Pratham Books on which stories can be read, downloaded, translated, versioned or printed."

#@javascript
#Scenario: Validate social icon instagram in the side bar

  #When I login as "user@sample.com" with "password"
  #When I click on "instagram" icon in the side bar
  #And I access the new tab
  #When I wait 10 seconds
  #Then I get the URL of current page
  #Then I should see "pbstoryweaver"

#Feature: Validate Home page without login

@javascript
Scenario: validate all the links without login
  Given I am on the Home page
  Then I should see "Log In"
  Then I should see "Sign Up"

  Then I should see "read"
  Then I should see "create"
  Then I should see "translate"
  Then I should see "about"

  Then I should see "STORIES"
  Then I should see "READS"
  Then I should see "LANGUAGES"

  Then I should see "editor's picks"
  Then I should see "new arrivals"
  Then I should see "most read"
  Then I should see "most liked"

  Then I should see "StoryWeaver"
  Then I should see "FAQs"
  Then I should see "T&C"
  Then I should see "Contact"

  Then I should see "open licensed content"
  Then I should see "privacy policy"
  Then I should see "pratham books"
  Then I should see "credits"

  Then I should see "Privacy Policy"
  Then I should see "Terms & Conditions"
  Then I should see "Pratham Books"
  Then I should see "All Rights Reserved."

  Then I should see "Except where otherwise noted, content on this site is licensed under a Creative Commons Attribution 4.0 License International (CC-BY-4.0)"
  Then I should see "follow us on"

@javascript
Scenario: Validating all the buttons without login

  Given I am on the Home page
  When I click "Read"
  Then I should see "stories found"

  When I click "Translate"
  Then I should see "Welcome to the StoryWeaver translator!"

  When I click "About"
  Then I should see "Many languages, formats, and stories for children. All open source."

  When I click "Create"
  Then I should see "Log in"

@javascript
Scenario: Validate social icon facebook in the side bar

  Given I am on the Home page
  When I click on "facebook" icon in the side bar
  And I access the new tab
  Then I should see "Pratham Books' StoryWeaver"

@javascript
Scenario:  Validate social icon twitter in the side bar

  Given I am on the Home page
  When I click on "twitter" icon in the side bar
  And I access the new tab
  Then I should see "An open source platform for stories by @prathambooks. Read, play, remix!"

@javascript
Scenario: Validate social icon youtube in the side bar

  Given I am on the Home page
  When I click on "youtube" icon in the side bar
  And I access the new tab
  Then I should see "Pratham Books StoryWeaver"

@javascript
Scenario: Validate social icon blog in the side bar

  Given I am on the Home page
  When I click on "blog" icon in the side bar
  And I access the new tab
  Then I should see "StoryWeaver is an open source digital platform from Pratham Books on which stories can be read, downloaded, translated, versioned or printed."

#@javascript
#Scenario: Validate social icon instagram in the side bar
 
  #Given I am on the Home page
  #When I click on "instagram" icon in the side bar
  #And I access the new tab
  #Then I should see "pbstoryweaver"

@javascript
Scenario: Validate social icon facebook
 
  Given I am on the Home page
  When I click on icon "facebook"
  And I access the new tab
  When I get the URL of current page
  Then I should see "Pratham Books' StoryWeaver"

@javascript
Scenario: Validate social icon twitter
 
  Given I am on the Home page
  When I click on icon "twitter"
  And I access the new tab
  Then I should see "Tweets"

@javascript
Scenario: Validate social icon youtube

  Given I am on the Home page
  When I click on icon "youtube-play"
  And I access the new tab
  Then I should see "Pratham Books StoryWeaver"

@javascripts
Scenario: Validate social icon blog

  Given I am on the Home page
  When I click on icon "rss"
  And I access the new tab
  Then I should see "StoryWeaver is an open source digital platform from Pratham Books"
