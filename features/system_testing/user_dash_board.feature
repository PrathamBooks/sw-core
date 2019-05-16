Feature: UserDashBoard

Scenario: To Validate User should be able to update the password from dashboard
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  And I select DashBoard
  And I select "My Details" tab under Dashboard
  And I change my password from "password" to "password1"
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password1                   |
  Then I should navigate to profile dashboard successfully

Scenario: To Validate read page filters are auto applied based on the preferences applied in user details

  When I create "1" stories with category "Biographies" and language as "English" with reading_level "0" from the author as "pratham" with the title "mockstory" and the flaggings_count as "0" and with org "admin@example.com"
  When I create "1" stories with category "Biographies" and language as "Hindi" with reading_level "0" from the author as "pratham" with the title "Hindi Story" and the flaggings_count as "0" and with org "admin@example.com"

  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  And I select DashBoard
  And I select "My Details" tab under Dashboard
  And I update the following details of the user
    | Reading Levels       | Level 1: Easy words, word repetition, less than 250 words |
    | Language Preferences | English |
  And I navigate to Read Page
  Then I Should see "English" filters in applied section
  Then I Should see "Level 1" filters in applied section

Scenario: To Validate my published stories appears in the dashboard list of "My Published Stories"
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add images to the story
  And I publish the story
  And I select DashBoard
  And I select "My Published Stories" tab under Dashboard
  Then I should see newly published stories in the dashboard list

Scenario: To Validate draft stories appears in the dashboard list of "My Draft Stories"
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add images to the story
  And I draft the story
  And I select DashBoard
  When I select "My Drafts" tab under Dashboard
  Then I should see newly drafted stories in the dashboard list

Scenario: To Validate the delete action under "My Drafts"
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add images to the story
  And I draft the story
  And I select DashBoard
  And I select "My Drafts" tab under Dashboard
  Then I should see newly drafted stories in the dashboard list
  When I delete the story from the list in the draft tab of dashboard
  Then I select "My Drafts" tab under Dashboard
  And I shouldnot see newly drafted stories in the dashboard list

Scenario: To Validate the edit action under "My Drafts"
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add images to the story
  And I draft the story
  And I select DashBoard
  And I select "My Drafts" tab under Dashboard
  Then I should see newly drafted stories in the dashboard list
  When I edit the newly created story from the list in dashboard
  And I publish the story
  And I select DashBoard
  And I select "My Drafts" tab under Dashboard
  Then I shouldnot see newly drafted stories in the dashboard list
  And I select "My Published Stories" tab under Dashboard
  Then I should see newly drafted stories in the dashboard list

Scenario: To Validate user is able to update the details successfully
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  And I select DashBoard
  And I select "My Details" tab under Dashboard
  Then I update the following details of the user
    | First Name | automation |
    | Last Name  | automating |
  And I select DashBoard
  And I select "My Details" tab under Dashboard
  Then I should see the updated details of the user
    | First Name | automation |
    | Last Name  | automating |

Scenario: To Validate my published stories appears in the dashboard list of "My Published Stories under Edit"[Edit button validation, it has to go to story details page]
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Create Page
  And I fill the create story popup with default
  And I add images to the story
  And I publish the story
  And I select DashBoard
  And I select "My Published Stories" tab under Dashboard
  Then I should see newly published stories in the dashboard list
  When I edit the newly created story from the published list
  When I Move to latest window session
  And I edit the story from story details page
  And I draft the story
  And I select DashBoard
  And I select "Published Stories Under Edit" tab under Dashboard
  Then I should see newly drafted stories in the dashboard list

Scenario: To Validate User should be able to click on become an organizational user
   Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  And I select DashBoard
  And I select "My Details" tab under Dashboard
  And I become an organisational user
    | COUNTRY NAME | Cuba |
    | NAME OF THE ORGANISATION       | PrathamBooks |
    | NUMBER OF CLASSROOMS | 5 |
    | NUMBER OF CHILDREN IMPACTED (APPROXIMATELY) | 5 |
    | WHICH STATES/CITIES ARE YOU WORKING IN? | 5 |

#Scenario: To Validate my published stories appears in the dashboard list of "My Illustrations"[click on image or image title it has to redirect to image details page]

# --To Do--
# Submitted and Deactived stories[pls keep these under comment we can take up these later]
# For derivative stories also we will keep on hold, after translation we will take up this scenario.
