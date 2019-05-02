Feature: List Page

Background:

  When I create "10" stories with "Fantasy" and "English" and "2" by "user@sample.com" with "English story of orginal type" and "nil"

  When I create list with "4" stories with category "History and Culture" has number of reads as "5" with likes of "5" by "Inspiring Behaviour"

  When I create list with "5" stories with category "History and Culture" has number of reads as "5" with likes of "5" by "Indian Culture and History for Grades 4 and 5"

  When I create list with "2" stories with category "History and Culture" has number of reads as "5" with likes of "5" by "Society and Rights for Grades 4, 5 and above"

  When I create list with "2" stories with category "Inspiring Stories" has number of reads as "15" with likes of "3" by "Flora, Fauna and Ecosystems"

  When I create list with "1" stories with category "Writing Prompts" has number of reads as "10" with likes of "7" by "Wordless Picture Books"

  When I create "1" stories with category "Fantasy" and language as "English" with reading_level "2" from the author as "pratham" with the title "Handmade in india" and the flaggings_count as "0" and with org "admin@prathambooks.org"

  When I create "1" stories with category "Fantasy" and language as "English" with reading_level "2" from the author as "pratham" with the title "Asura and boy" and the flaggings_count as "4" and with org "admin@prathambooks.org"

  When I create "1" stories with category "Fantasy" and language as "English" with reading_level "2" from the author as "pratham" with the title "The boat ride" and the flaggings_count as "4" and with org "admin@prathambooks.org"

  When I create "1" stories with category "Fantasy" and language as "English" with reading_level "2" from the author as "pratham" with the title "glassdoor" and the flaggings_count as "4" and with org "admin@prathambooks.org"

  When I create "1" stories with category "Fantasy" and language as "English" with reading_level "2" from the author as "pratham" with the title "samplestory" and the flaggings_count as "4" and with org "admin@prathambooks.org"

Scenario: To Validate the listpage
  Given I open StoryWeaver
  When I navigate to List Page
  Then I should be in list page

Scenario: To Validate available filters in list page
  Given I open StoryWeaver
  When I navigate to List Page
  Then I should see "Categories" in Filters section of list page

Scenario: To Validate available sort by filter options in list page
  Given I open StoryWeaver
  When I navigate to List Page
  Then I should the all the sorty by filter options in the list drop down

Scenario: To Validate List Details page
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to List Page
  And I choose "Wordless Picture Books" following list from list page
  Then I validate listdetails page

Scenario: To Validate Categories filters in list page
  Given I login to StoryWeaver with
    |Email    | admin@prathambooks.org             |
    |Password | prathambooks                    |
  When I navigate to List Page
  And I apply the following filters in list page
    | Categories   | History and Culture      |
  Then I Should see "History and Culture" filters in applied section

Scenario: To Validate like a list from listdetails page with login
  Given I login to StoryWeaver with
    |Email    | user@sample.com        |
    |Password | password               |
  When I navigate to List Page
  And I choose "Wordless Picture Books" following list from list page
  Then I get like count of that list
  And I like a list in listdetails page
  Then I validate like count "should" incremented in listdetails page

Scenario: To Validate like a list from listdetails page without login
  Given I open StoryWeaver
  When I navigate to List Page
  And I choose "Wordless Picture Books" following list from list page
  Then I get like count of that list
  And I like a list in listdetails page
  Then I validate like count "shouldn't" incremented in listdetails page
  Then I should see Log In and signup popup

Scenario: To Validate DOWNLOAD from listdetails page without login
  Given I open StoryWeaver
  When I navigate to List Page
  And I choose "Wordless Picture Books" following list from list page
  When I choose "Download" from listdetails page
  Then I should see Log In and signup popup

Scenario: To Validate read views count from storydetails page
  When I disable the list feedback popup for "user@sample.com"
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to List Page
  And I choose "Wordless Picture Books" following list from list page
  And I get read count of the list
  Then I choose a "English story of orginal type" story from listdetails page
  Then I should see story reader popup
  And I read the complete story
  When I "Sign Out" from storyweaver
  Given I login to StoryWeaver with
    |Email    | admin@prathambooks.org       |
    |Password | prathambooks              |
  When I navigate to List Page
  And I choose "Wordless Picture Books" following list from list page
  Then I validate read count "should" incremented in listdetails page

Scenario: To Validate Publisher from listdetails page
  When I disable the list feedback popup for "user@sample.com"
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to List Page
  And I choose "Wordless Picture Books" following list from list page
  When I choose "Pratham books" publisher from listdetails page
  Then I validate organization details page

Scenario: To Validate SHARE from listdetails page
  Given I login to StoryWeaver with
  |Email    | user@sample.com        |
  |Password | password               |
  When I navigate to List Page
  And I choose "Wordless Picture Books" following list from list page
  When I choose "Share" from listdetails page
  Then I should see share options on listdetails page

Scenario: To Validate smiley rating from read story popup in listdetails page
  When I disable the list feedback popup for "user@sample.com"
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to List Page
  And I choose "Wordless Picture Books" following list from list page
  Then I get like count of that list
  Then I choose a "English story of orginal type" story from listdetails page
  Then I should see story reader popup
  And I read the complete story with smiley rating "like"
  Then I validate like count "shouldn't" incremented in listdetails page

Scenario: To Validate next read suggestions from read story popup in listdetails page
  When I disable the list feedback popup for "user@sample.com"
  Given I login to StoryWeaver with
    |Email    | user@sample.com       |
    |Password | password              |
  When I navigate to List Page
  And I choose "Wordless Picture Books" following list from list page
  And I get read count of the list
  Then I choose a "English story of orginal type" story from listdetails page
  Then I should see story reader popup
  And I choose "glassdoor" a story from nextread suggestions
  Then I should see story reader popup
  And I read the complete story
  Then I validate read count "shouldn't" incremented in listdetails page

Scenario: To Validate read views count from storydetails page without login
  Given I open StoryWeaver
  When I navigate to List Page
  And I choose "Wordless Picture Books" following list from list page
  And I get read count of the list
  Then I choose a "English story of orginal type" story from listdetails page
  Then I should see story reader popup
  And I read the complete story
  Then I validate read count "shouldn't" incremented in listdetails page

Scenario: To Validate list feedback form
  Given I open listfeedback form
  Then I validate listfeedback form
  And I fill and submit the list feedback form
  Then I validate feedback response
#---Need to take sperately to handle Download and Save to offline functionalities---

#Scenario: To Validate SAVE TO OFFLINE from listdetails page
#  Given I login to StoryWeaver with
#    |Email    | user@sample.com        |
#    |Password | password               |
#  When I navigate to List Page
#  And I choose "Wordless Picture Books" following list from list page
#  When I choose "Save to offline library" from listdetails page
#  Then I should see "Delete from offline library" in story details page

#Scenario: To Validate SAVE TO OFFLINE from listdetails page without login
#  Given I open StoryWeaver
#  When I navigate to List Page
#  And I choose "Wordless Picture Books" following list from list page
#  When I choose "Save to offline library" from listdetails page
#  Then I should see Log In and signup popup

#Scenario: To Validate DOWNLOAD from listdetails page
# Given I login to StoryWeaver with
#   |Email    | user@sample.com        |
#   |Password | password               |
#  When I navigate to List Page
# And I choose "Wordless Picture Books" following list from list page
#  When I choose "Download" from listdetails page