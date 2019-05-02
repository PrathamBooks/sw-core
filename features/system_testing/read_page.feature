Feature: Read Page
Background:
  When I create "1" stories with category "Biographies" and language as "English" with reading_level "3" from the author as "pratham" with the title "mockstory" and the flaggings_count as "0" and with org "admin@prathambooks.org"

Scenario: To Validate the story card details
  Given I open StoryWeaver
  When I navigate to Read Page

Scenario: To Validate available filters for normal user
  Given I login to StoryWeaver with
  |Email    | user@sample.com             |
  |Password | password                    |
  When I navigate to Read Page
  Then I should see "Type,Levels,Publishers,Categories,Languages" in Filters section of read page

Scenario: To Validate available filters for content manager
  Given I login to StoryWeaver with
  |Email    | content_manager@sample.com   |
  |Password | content_manager              |
  When I navigate to Read Page
  Then I should see "Type,Levels,Publishers,Categories,Languages,Origin,Story Status" in Filters section of read page

Scenario: To Validate Translating Missing is absent in available filter options
  Given I open StoryWeaver
  When I navigate to Read Page
  Then I vaildate Translation missing is not available in all filters in Read Page

Scenario: To Validate Translating Missing is absent in available filter options for CM login
  Given I login to StoryWeaver with
  |Email    | content_manager@sample.com   |
  |Password | content_manager              |
  When I navigate to Read Page
  Then I vaildate Translation missing is not available in all filters in Read Page

Scenario: To Validate available sort by filter options in read page
  Given I open StoryWeaver
  When I navigate to Read Page
  Then I should the all the sorty by filter options in the drop down

Scenario: To Validte details Quickview details of the story with read page details
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  And I get the story details of first story
  And I click on quickview
  Then I should see QuickView popup
  And I Validate the QuikView popup details with read page details


Scenario: To Validate read story from quick view menu
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  And I choose "Read Story" from quick view
  Then I should see story reader popup
  And I read the complete story

Scenario: To Validate story details of a story from quick view details(story card -> quick view -> View details)
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  And I get the story details of first story
  And I click on quickview
  Then I should see QuickView popup
  When I select "View details" from quick view popup
  Then I should be navigated to story details page
  And I validate the details of the story with read page story card details

Scenario: To Validate story read from quick view popup(story card -> quick view -> Read now)
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  And I get the story details of first story
  And I click on quickview
  Then I should see QuickView popup
  When I select "Read Now" from quick view popup
  Then I should see story reader popup
  And I read the complete story

Scenario: To Validate ADD TO MY BOOKSHELF from quick view menu
  Given I login to StoryWeaver with
  |Email    | user@sample.com       |
  |Password | password              |
  When I navigate to Read Page
  And I choose first story in read page
  Then I choose "Add to My Bookshelf" from quick view
  Then I should see "Delete from My Bookshelf" in more actions of quick view
  When I navigate to story details of first story
  Then I should see "Delete from My Bookshelf" in story details page

Scenario: To Validate ADD TO MY BOOKSHELF throws LogIn popup from quick view menu in read page
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  And I choose "Add to My Bookshelf" from quick view
  Then I should see Log In popup

Scenario: To Validate SAVE TO OFFLINE from quick view menu
  Given I login to StoryWeaver with
  |Email    | user@sample.com        |
  |Password | password               |
  When I navigate to Read Page
  And I choose first story in read page
  And I choose "Save to offline library" from quick view
  Then I should see "Delete from offline library" in more actions of quick view
  When I navigate to story details of first story
  Then I should see "Delete from offline library" in story details page

Scenario: To Validate SAVE TO OFFLINE throws LogIn popup from quick view menu in read page
  Given I open StoryWeaver
  When I navigate to Read Page
  And I choose first story in read page
  And I choose "Save to offline library" from quick view
  Then I should see Log In popup

Scenario: To Validate Publishers filters
  When I create "1" stories with category "Fantasy" and language as "Bengali" with reading_level "1" from the author as "usersample" with the title "creative thoughts" and the flaggings_count as "0" and with org "user@sample.com"
  When I create "1" stories with category "Fiction" and language as "French" with reading_level "3" from the author as "contentmanger" with the title "Logical Thinking" and the flaggings_count as "0" and with org "content_manager@sample.com"
  When I create "1" stories with category "Biographies" and language as "Spanish" with reading_level "0" from the author as "contentmanger" with the title "GlassDoor" and the flaggings_count as "0" and with org "autotranslate@yopmail.com"

  Given I login to StoryWeaver with
  |Email    | user@sample.com       |
  |Password | password              |
  When I navigate to Read Page
  When I apply the following filters in read page
  | Publishers   | GlassDoor        |
  Then I Should see "GlassDoor" filters in applied section
  Then I Should see "GlassDoor" story in the read page list

Scenario: To Validate Categories filters
  When I create "1" stories with category "Fantasy" and language as "Bengali" with reading_level "1" from the author as "usersample" with the title "creative thoughts" and the flaggings_count as "0" and with org "user@sample.com"
  When I create "1" stories with category "Fiction" and language as "French" with reading_level "3" from the author as "contentmanger" with the title "Logical Thinking" and the flaggings_count as "0" and with org "content_manager@sample.com"

  Given I login to StoryWeaver with
  |Email    | user@sample.com       |
  |Password | password              |
  When I navigate to Read Page
  When I apply the following filters in read page
  | Categories   | Biographies      |
  Then I Should see "Biographies" filters in applied section
  Then I Should see "mockstory" story in the read page list

Scenario: To Validate Languages filters
  When I create "1" stories with category "Fantasy" and language as "Bengali" with reading_level "1" from the author as "usersample" with the title "creative thoughts" and the flaggings_count as "0" and with org "user@sample.com"
  When I create "1" stories with category "Fiction" and language as "French" with reading_level "3" from the author as "contentmanger" with the title "Logical Thinking" and the flaggings_count as "0" and with org "content_manager@sample.com"

  Given I login to StoryWeaver with
  |Email    | user@sample.com       |
  |Password | password              |
  When I navigate to Read Page
  When I apply the following filters in read page
  | Languages   | Bengali            |
  Then I Should see "Bengali" filters in applied section
  Then I Should see "creative thoughts" story in the read page list

Scenario: To Validate Levels filters
  When I create "1" stories with category "Fantasy" and language as "Bengali" with reading_level "0" from the author as "usersample" with the title "creative thoughts" and the flaggings_count as "0" and with org "user@sample.com"
  When I create "1" stories with category "Fiction" and language as "French" with reading_level "3" from the author as "contentmanger" with the title "Logical Thinking" and the flaggings_count as "0" and with org "content_manager@sample.com"
  When I create "1" stories with category "Biographies" and language as "Spanish" with reading_level "0" from the author as "contentmanger" with the title "GlassDoor" and the flaggings_count as "0" and with org "autotranslate@yopmail.com"

  Given I login to StoryWeaver with
  |Email    | user@sample.com       |
  |Password | password              |
  When I navigate to Read Page
  And I apply level "1" under Level filter in read page
  Then I Should see "LEVEL 1" filters in applied section
  Then I Should see "creative thoughts" story in the read page list
  
  Scenario: To Validate Origin filters for content manager
  When I create "1" stories with category "Fiction" and language as "French" with reading_level "3" from the author as "contentmanger" with the title "Logical Thinking" and the flaggings_count as "0" and with org "content_manager@sample.com"
  When I create "1" stories with "Fantasy" and "English" and "3" by "content_manager@sample.com" with "English story of Re-Levelled type" and "relevelled"
  Given I login to StoryWeaver with
  |Email    | content_manager@sample.com   |
  |Password | content_manager              |
  When I navigate to Read Page
  When I apply the following filters in read page
  | Origin   | Re-level            |
  Then I Should see "Re-level" filters in applied section
  Then I Should see "English story of Re-Levelled type" story in the read page list

Scenario: To Validate Story Status filters for content manager
  When I create "1" stories with category "Fiction" and language as "French" with reading_level "3" from the author as "contentmanger" with the title "Logical Thinking" and the flaggings_count as "0" and with org "content_manager@sample.com"
  When I create one story with status as "draft" and story title as "Draft Test story" for the user "content_manager@sample.com" and contest presence "false"
  Given I login to StoryWeaver with
  |Email    | content_manager@sample.com   |
  |Password | content_manager              |
  When I navigate to Read Page
  When I apply the following filters in read page
  | Story Status   | Draft            |
  Then I Should see "Draft" filters in applied section
  Then I Should see "Draft Test story" story in the read page list
