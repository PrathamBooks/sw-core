Feature: Image Tab

Background:
  When I create one illustration for "user@sample.com" with title "Test Image" with Publisher "Pratham Books", Category "Animals & Birds" and Style "Black and white"

Scenario: To Validate Publishers filter section for normal user
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Image Page
  Then I should see "Publishers,Categories,Styles" in Filters section of image page
  When I apply the following filters in read page
    | Publishers   | Pratham Books             |
  Then I Should see "Pratham Books" filters in applied section
  Then I Should see "Test Image" illustration in the image page list

Scenario: To Validate Categories filter section for normal user
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Image Page
  When I apply the following filters in read page
    | Categories   | Animals & Birds          |
  Then I Should see "Animals & Birds" filters in applied section
  Then I Should see "Test Image" illustration in the image page list

Scenario: To Validate Styles filter section for normal user
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Image Page
  When I apply the following filters in read page
    | Styles  | Black and white            |
  Then I Should see "Black and white" filters in applied section
  Then I Should see "Test Image" illustration in the image page list

Scenario: To Validate SortBy filter section for normal user
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Image Page
  Then I should see all the sortby filter options in the drop down

Scenario: To Validate uplode image for guest user
  Given I open StoryWeaver
  When I navigate to Image Page
  And I select upload image
  Then LogIn popup should show up

Scenario: To Validate upload image for normal user and same is reflected in dashboard
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Image Page
  And I select upload image
  And I fill the image upload fields with following details
    | ImageType | burger-logo.png       |
  And I upload the image successfully
  And I select Profile from UserDashBoard
  And I select "Illustrations" tab in Profile dashboard
  Then I should see newly uploaded illustration in the list

Scenario: To Validate Publisher should be able to upload png images
  Given I login to StoryWeaver with
    |Email    | orguser@example.com       |
    |Password | password                 |
  When I navigate to Image Page
  And I select upload image
  And I fill the image upload fields with following details
    | ImageType | burger-logo.png |
    | IllustratorEmail | orguser@example.com |
    | IllustrtorFirstname | Pratham Books |
  And I upload the image successfully
  And I select Profile from UserDashBoard
  And I select "Illustrations" tab in Profile dashboard

Scenario: To Validate upload 'jpg image' for normal user and same is reflected in dashboard
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Image Page
  And I select upload image
  And I fill the image upload fields with following details
    | ImageType | Staff_Room.jpg       |
  And I upload the image successfully
  And I select Profile from UserDashBoard
  And I select "Illustrations" tab in Profile dashboard
  Then I should see newly uploaded illustration in the list

Scenario: To Validate Publisher should be able to upload jpg images
  Given I login to StoryWeaver with
    |Email    | orguser@example.com       |
    |Password | password                 |
  When I navigate to Image Page
  And I select upload image
  And I fill the image upload fields with following details
    | ImageType | Staff_Room.jpg |
    | IllustratorEmail | orguser@example.com |
    | IllustrtorFirstname | Pratham Books |
  And I upload the image successfully
  And I select Profile from UserDashBoard
  And I select "Illustrations" tab in Profile dashboard

Scenario: To Validate CM should be able to upload jpg images
  Given I login to StoryWeaver with
    |Email    | content_manager@sample.com   |
    |Password | content_manager              |
  When I navigate to Image Page
  And I select upload image
  And I fill the image upload fields with following details
    | ImageType | Staff_Room.jpg |
    | IllustratorEmail | content_manager@sample.com |
    | IllustrtorFirstname | Content Manager |
  And I upload the image successfully
  And I select Profile from UserDashBoard
  And I select "Illustrations" tab in Profile dashboard
  Then I should see newly uploaded illustration in the list

Scenario: To Validate Like functionality of a image
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Image Page
  And I select first image
  Then I should be in image details page
  When I get the image details 
  And I like the image
  When I navigate to Image Page
  And I select first image
  Then I should see like count is incremented by "1"

Scenario: To Validate Report functionality of a image
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Image Page
  And I select first image
  Then I should be in image details page
  When I get the image details 
  And I like the image
  When I navigate to Image Page
  And I select first image
  Then I should see like count is incremented by "1" for the illustration

Scenario: To Validate Views count of a image
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Image Page
  And I select first image
  Then I should be in image details page
  When I get the image details 
  When I navigate to Image Page
  And I select first image
  Then I should see view count is incremented by "1" for the illustration

Scenario: To Validate normal user should not be able to upload gif images
  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Image Page
  And I select upload image
  And I fill the image upload fields with following details
    | ImageType | rotating_earth.gif        |
  And I upload the image successfully
  Then I should see error message regarding Image upload
    | Message | PNG and JPEG are the only supported formats |

Scenario: To Validate CM should be able to upload gif images
  Given I login to StoryWeaver with
    |Email    | content_manager@sample.com   |
    |Password | content_manager              |
  When I navigate to Image Page
  And I select upload image
  And I fill the image upload fields with following details
    | ImageType | rotating_earth.gif |
    | IllustratorEmail | content_manager@sample.com |
    | IllustrtorFirstname | Content Manager |
  And I upload the image successfully
  And I select Profile from UserDashBoard
  And I select "Illustrations" tab in Profile dashboard
  Then I should see newly uploaded illustration in the list

Scenario: To Validate Publisher should be able to upload gif images
  Given I login to StoryWeaver with
    |Email    | orguser@example.com       |
    |Password | password                 |
  When I navigate to Image Page
  And I select upload image
  And I fill the image upload fields with following details
    | ImageType | rotating_earth.gif |
    | IllustratorEmail | orguser@example.com |
    | IllustrtorFirstname | Pratham Books |
  And I upload the image successfully
  And I select Profile from UserDashBoard
  And I select "Illustrations" tab in Profile dashboard
  Then I should see newly uploaded illustration in the list

Scenario: To Validate download options for a normal user
  When I create one illustration for "user@sample.com" with title "Extra" with Publisher "Pratham Books", Category "Animals & Birds" and Style "Black and white"
  When I create one illustration for "user@sample.com" with title "Extra1" with Publisher "Pratham Books", Category "Animals & Birds" and Style "Black and white"
  When I create one illustration for "user@sample.com" with title "Extra2" with Publisher "Pratham Books", Category "Animals & Birds" and Style "Black and white"
  When I create one illustration for "user@sample.com" with title "Extra3" with Publisher "Pratham Books", Category "Animals & Birds" and Style "Black and white"
  When I create one illustration for "user@sample.com" with title "Extra4" with Publisher "Pratham Books", Category "Animals & Birds" and Style "Black and white"

  Given I login to StoryWeaver with
    |Email    | user@sample.com             |
    |Password | password                    |
  When I navigate to Image Page
  And I choose download Multiple Images
  Then I should see "JPEG, HiRes JPEG" in the download option list
  Then I should see validation message for download limit

Scenario: To Validate create story in image details
  Given I login to StoryWeaver with
    |Email    | content_manager@sample.com   |
    |Password | content_manager              |
  When I navigate to Image Page
  And I select first image
  Then I should be in image details page
  And I select create story from image details page
  Then I should see create popup

Scenario: To Validate share from image details page
  Given I login to StoryWeaver with
    |Email    | content_manager@sample.com   |
    |Password | content_manager              |
  When I navigate to Image Page
  And I select first image
  Then I should be in image details page
  And I get story weaver session details
  And I share the image through "Twitter"
  And I navigate to external "twitter" tab
  Then I verify it is external "twitter" page
  When I navigate back to storyweaver tab
  And I share the image through "Facebook"
  And I navigate to external "Facebook" tab
  Then I verify it is external "Facebook" page
  When I navigate back to storyweaver tab
  And I share the image through "Google+"
  And I navigate to external "Google" tab
  Then I verify it is external "Google" page
#Scenario: To Validate normal user should not be able to upload csv files

#  Given I login to StoryWeaver with
#    |Email    | user@sample.com             |
#    |Password | password                    |
#  When I navigate to Image Page
#  And I select upload image
#  And I fill the image upload fields with following details
#    | ImageType | storyweaver.csv        |
#  And I upload the image successfully
#  Then I should see error message regarding Image upload
#   | Message | GIF, PNG and JPEG are the only supported formats |