Feature: My Bookshelf

Background:

  When I create "1" stories with category "Fantasy" and language as "English" with reading_level "2" from the author as "pratham" with the title "Handmade in india" and the flaggings_count as "0" and with org "admin@example.com"

  When I create "1" stories with category "Fantasy" and language as "English" with reading_level "2" from the author as "pratham" with the title "Asura and boy" and the flaggings_count as "4" and with org "admin@example.com"

  When I create "1" stories with category "Fantasy" and language as "English" with reading_level "2" from the author as "pratham" with the title "The boat ride" and the flaggings_count as "4" and with org "admin@example.com"

  When I create "1" stories with category "Fantasy" and language as "English" with reading_level "2" from the author as "pratham" with the title "glassdoor" and the flaggings_count as "4" and with org "admin@example.com"

  When I create "1" stories with category "Fantasy" and language as "English" with reading_level "2" from the author as "pratham" with the title "samplestory" and the flaggings_count as "4" and with org "admin@example.com"

Scenario: Creating My bookshelf.
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Read Page
  And I choose first story in read page
  Then I choose "Add to My Bookshelf" from quick view
  And I choose "Asura and boy" story in read page
  Then I choose "Add to My Bookshelf" from storydetails page
  When I select Profile from UserDashBoard
  And I select "My Bookshelf" tab in Profile dashboard
  Then I should see the story added to my bookshelf

Scenario: To Validate Delete a stroy from my bookshelf
  When I disable the list feedback popup for "user@sample.com"
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Read Page
  And I choose first story in read page
  Then I choose "Add to My Bookshelf" from quick view
  And I choose "Asura and boy" story in read page
  Then I choose "Add to My Bookshelf" from storydetails page
  When I select Profile from UserDashBoard
  And I select "My Bookshelf" tab in Profile dashboard
  Then I should see the story added to my bookshelf
  When I edit stories in my bookshelf
  Then I perform "Delete" action for this story "Handmade in india" in my bookshelf page
  And I select "Yes" from deletepopup in my bookshelf page
  Then I saved edited changes in my bookshelf
  Then I validate deleted story in my bookshelf

Scenario: To Validate Add 'How to use' a stroy from my bookshelf
  When I disable the list feedback popup for "user@sample.com"
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Read Page
  And I choose first story in read page
  Then I choose "Add to My Bookshelf" from quick view
  And I choose "Asura and boy" story in read page
  Then I choose "Add to My Bookshelf" from storydetails page
  When I select Profile from UserDashBoard
  And I select "My Bookshelf" tab in Profile dashboard
  Then I should see the story added to my bookshelf
  And I validate listdetails page
  Then I edit stories in my bookshelf
  Then I perform "Add ‘How to Use’" action for this story "Asura and boy" in my bookshelf page
  And I fill "About story" story description
  Then I saved edited changes in my bookshelf
  And I validate how to use description in my bookshelf

Scenario: To Validate Move Up/Move Down a stroy from my bookshelf
  When I disable the list feedback popup for "user@sample.com"
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Read Page
  And I choose first story in read page
  Then I choose "Add to My Bookshelf" from quick view
  And I choose "Asura and boy" story in read page
  Then I choose "Add to My Bookshelf" from storydetails page
  When I select Profile from UserDashBoard
  And I select "My Bookshelf" tab in Profile dashboard
  Then I should see the story added to my bookshelf
  And I validate listdetails page
  Then I edit stories in my bookshelf
  And I get the position of the "Handmade in india" story in my bookshelf page
  Then I perform "Move Down" action for this story "Handmade in india" in my bookshelf page
  Then I saved edited changes in my bookshelf
  And I validate position of particular storyin listdetails page

Scenario: To Validate List description in my bookshelf
  When I disable the list feedback popup for "user@sample.com"
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Read Page
  And I choose first story in read page
  Then I choose "Add to My Bookshelf" from quick view
  And I choose "Asura and boy" story in read page
  Then I choose "Add to My Bookshelf" from storydetails page
  When I select Profile from UserDashBoard
  And I select "My Bookshelf" tab in Profile dashboard
  Then I should see the story added to my bookshelf
  And I validate listdetails page
  Then I edit stories in my bookshelf
  And I fill list description with "Introduced to environmental topics" content
  Then I saved edited changes in my bookshelf
  Then I validate list description
