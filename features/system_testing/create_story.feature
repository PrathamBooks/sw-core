Feature: Create Story

Background: some users have been added to database
  Given the following users exist:
    | first_name | email | password | password_confirmation | confirmed_at | 
    | storyweaver | automation@yopmail.com | automation@123 | automation@123 | 2017-03-07 12:54:45.222844 |

    Given the following languages exist:
    | name | can_transliterate | script |
    | English | false | english |

Given the following storycategory exist:
    | name |
    | Fiction |

  Given the following illustrationcategory exist:
    | name |
    | People |

  Given the following illustrationstyle exist:
    | name |
    | Watercolour |

  Given the following storypagetemplate exist:
    | name | default | orientation | image_position | content_position | image_dimension | content_dimension |
    | sp_h_iL50_cR50 | true | landscape | left | right | 50 | 50 |
    | sp_h_iT66_cB33 |  | landscape | top | bottom | 66.67 | 33.33|
    | sp_h_iL66_cR33 |  | landscape | left | right | 66.67 | 33.33 |
    | sp_h_iT75_cB25 |  | landscape | top | bottom | 75 | 25 |
    | sp_h_i100 |  | landscape | fill | nil | 100 | 0 |
    | sp_h_c100 |  | landscape | nil | fill | 0 | 100 |
    | sp_h_iB66_cT33 |  | landscape | bottom | top | 66.67 | 33.33 |
    | sp_h_text_overlay |  | landscape | background | foreground | 100 | 76 |
    | sp_h_text_overlay1 |  | landscape | background | foreground | 100 | 80 |
    | sp_v_iT50_cB50 | true | portrait | top | bottom | 50 | 50 |
    | sp_v_iB66_cT33 |  | portrait | bottom | top | 66.67 | 33.33 |
    | sp_v_iB66_cT33 |  | portrait | top | bottom | 66.67 | 33.33 |
    | sp_v_i100 |  | portrait | fill | nil | 100 | 0 |
    | sp_v_i100 |  | portrait | nil | fill | 0 | 100 |
    | sp_v_iT75_cB25 |  | portrait | top | bottom | 75 | 25 |

  Given the following frontcoverpagetemplate exist:
    | name | default | orientation | image_position | content_position | image_dimension | content_dimension |
    | fc_h_iT50_cB50 |  | landscape | top | bottom | 50 | 50 |
    | fc_h_iT66_cB33 | true | landscape | top | bottom | 66..67 | 33.33 |
    | fc_v_iT50_cB50 |  | portrait | top | bottom | 50 | 50 |
    | fc_v_iT66_cB33 | true | portrait | top | bottom | 66.67 | 33 |

  Given the following backcoverpagetemplate exist:
    | name | default | orientation | image_position | content_position | image_dimension | content_dimension |
    | bc_h_c100 | true | landscape | nil | fill | 0 | 100 |
    | bc_v_c100 | true | portrait | nil | fill | 0 | 100 |

  Given the following backinnercoverpagetemplate exist:
    | name | default | orientation | image_position | content_position | image_dimension | content_dimension |
    | bic_h_c100 | true | landscape | nil | fill | 0 | 100 |
    | bic_v_c100 | true | portrait | nil | fill | 0 | 100 |

  Given the following dedicationpagetemplate exist:
    | name | default | orientation | image_position | content_position | image_dimension | content_dimension |
    | dd_h_c100 | true | landscape | nil | fill | 0 | 100 |
    | dd_v_c100 | true | portrait | nil | fill | 0 | 100 |

  Given the following illustrations exist:
    | name | image_file_name | license_type | copy_right_year | copy_right_holder_id | organization_id |
    | Automation | /home/scrach/spp/public/system/story-weaver/illustrations/1/original/prathambooks.png | CC BY 4.0 | 2016 | Illustrator | Pratham Books |
    | Automation | /home/scrach/spp/public/system/story-weaver/illustrations/1/original/hyderabad.jpeg | CC BY 4.0 | 2016 | Illustrator | Pratham Books |

@javascript
Scenario: Login to Create Story
  When I login as "user@sample.com" with "password"

#Validate Create Button/Link after Login to Storyweaver
  When I follow "Create"
  And I wait 20 seconds
  Then I should see Modal Form
  And I should see "Create New Book"
  When I fill in "story[title]" with "Automation Testing"
  When I click on "#story_language_id"
  And I wait 2 seconds
  When I select "Bengali" from "story[language_id]"
  And I wait 2 seconds
  When I choose "4"
  When I choose "landscape"
  Then I press "start with words"
  And I wait 20 seconds
  Then I should see "Welcome to our new story creator!"
  When I click "✕"
  Then I should not see "Welcome to our new story creator!"
  And I wait 5 seconds
  When I click at "add an image"
  And I wait 30 seconds
  When I click "upload image"
  And I wait 5 seconds
  When I fill in "illustration[name]" with "Automation_Testing_Illustration"
  When I click on category
  And I click checkbox category
  When I click on "#checkbox-terms-of-use"
  And I wait 5 seconds
  When I click on image style
  And I click checkbox imagestyle
  When I fill in "illustration[tag_list]" with "Testing_Illustration_Tag"
  When I attach image "10"

  When I click on "#illustration_license_type"
  When I select "CC BY 4.0" from "illustration[license_type]"
  Then I click on "#sub_illustration"
  And I wait 30 seconds
  When I select checkbox "#checkbox-terms-of-use"
  And I wait 5 seconds
  Then I click on "#sub_illustration"
  And I wait 30 seconds
  Then I select "Browse all images"
  And I expect "Successful!"
  Then I should see "Refine your search using one of the filters below"
  Then I should see "back to the editor"
  Then I should see "CATEGORIES"
  Then I should see "Sort by"
  When I click on new arrivals
  When I click on "#StorySortOptions"
  When I select "New Arrivals" from "StorySortOptions"

#Validation for add to current page, add/remove from favourites and save to favourites
  Then I should see "Automation_Testing_Illustration"
  When I select "favourites"
  Then I should see "Automation_Testing_Illustration"
  When I select image as remove from favourites
  Then I select "browse all images"
  When I select "favourites"
  And I wait 20 seconds
  Then I expect "Like a lot of images but not sure which ones you want to use in your story? Add them to your favourites while browsing. All the images you add to your favourites while creating or editing this story will be saved here."

  Then I select "browse all images"
  Then I should see "Automation_Testing_Illustration"
  When I select image as save to favourites
  When I select "favourites"
  And I wait 10 seconds
  Then I should see "testing_illustration_1"
  Then I select "browse all images"
  And I wait 5 seconds
  When I select image as add to current page
  And I wait 10 seconds
  When I select page "1"
  And I wait 5 seconds
  When I click at "add an image"
  And I wait 5 seconds
  When I select image as add to current page
  And I wait 10 seconds
  When I click on "#open_image_drawer"
  And I wait 5 seconds
  Then I expect "back to the editor"
  And I wait 5 seconds
  And I press "×"

  When I click "help"
  Then I should see "Welcome to our new story creator!"
  And I click "Exit"
  Then I should not see "Welcome to our new story creator!"
  When I click "help"
  Then I should see "Welcome to our new story creator!"
  When I select "Next" from the tour "Page Layout"

  Then I should see "Image Drawer"
  And I should see "open image drawer"
  When I select "Next" from the tour "Image Drawer"

  Then I should see "Add to favourites"
  And I should see "favourites"
  When I select "Next" from the tour "Favourites"

  Then I should see "Formatting"
  And I should see "Alignment"
  And I should see "Style"
  And I should see "Text Size"
  When I select "Next" from the tour "Formatting"

  Then I should see "Layouts"
  And I should see "Book Orientation"
  And I should see radio button "home-tab" as selected
  And I should see "Page Layout"
  When I select "Next" from the tour "Layouts"
  And I should see "Add a working title"
  And I should see "edit book information"
  When I select "Next" from the tour "Add a working title"
  Then I should see "Start Over"
  And I should see "discard draft"
  When I select "Done" from the tour "Start Over"
  Then I should not see "Start Over"

  When I select "edit book information"
  And I wait 5 seconds
  Then I expect "STORY TITLE"
  And I expect "Cancel"
  When I click on "modal-edit-book" containing "×"
  And I wait 5 seconds
  Then I should not see "STORY TITLE"
  When I click on "#insert_pages"
  Then I should see value "1" in "#numberOfPages"
  And I click "publish"
  And I wait 30 seconds
  Then I expect "PUBLISH: :Complete and verify book details"
  When I fill in "story[title]" with "story_for_automation_testing"
  And I wait 20 seconds
  And I select varnam text

  When I fill in "story[english_title]" with "story_for_automation_testing"
  When I fill in "story[synopsis]" with "Story_description"
  And I wait 20 seconds
  And I select varnam text
  When I fill in "story[tag_list]" with "Test tag"
  When I click on category
  And I wait 5 seconds
  When I click checkbox to choose story category
  And I select "next"
  And I wait 10 seconds
  When I select option from "review_book_covers" as "publish"
  And I wait 15 seconds
  And I close popup window
  #Then I should see "Wohooo! Your story will appear on the New Arrivals in a short while."

@javascript
Scenario: Validate clicking on Create Story without Login
  Given I am on the Home page
  And I wait 15 seconds
  Then I close popup window
  When I follow "Create"
  Then I wait 10 seconds
  Then I should see Login Modal Form
  Then I should see "Log In"
