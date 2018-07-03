Feature: Login to storyweaver page

@javascript
Scenario: Login to storyweaver page - valid email and password
  When I login as "user@sample.com" with "password"
  And I wait 5 seconds
  Then I expect "Common Man"
  #Then I expect "Signed in successfully."

@javascript
Scenario: Login to storyweaver page - validate signout
  When I login as "user@sample.com" with "password"
  When I click at "Common Man"
  When I click link "Sign Out"
  Then I should not see "Common Man"
  #Then I expect "Signed out successfully."

@javascript
Scenario: Login to storyweaver page - invalid email
  When I login as "user" with "password"
  Then I expect "Invalid email or password."

@javascript
Scenario: Login to storyweaver page - invalid password
  When I login as "user@sample.com" with "pa"
  Then I expect "Invalid email or password."

@javascript
Scenario: Login to storyweaver page - invalid email and password
  When I login as "user" with "pa"
  Then I expect "Invalid email or password."

@javascript
Scenario: Login to storyweaver page - empty email and password
  When I login as "" with ""
  Then I expect "Invalid email or password."

#Feature: Signup to storyweaver page

@javascript
Scenario: signup to the storyweaver page - with confirmation
  Given I am on the Signup page
  When I fill in "user[first_name]" with "automation"
  When I fill in "user[email]" with "automation1299@yopmail.com"
  When I fill in "user[password]" with "automation@123"
  When I fill in "user[password_confirmation]" with "automation@123"
  When I select signup Button
  And I wait 5 seconds
  #Then I expect "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
  #Then I follow the confirmation link in the confirmation email
  When I click link "Log In"
  When I fill in "user[email]" with "automation1299@yopmail.com"
  When I fill in "user[password]" with "automation@123"
  When I press "Log in"
  Then I should not see "Common Man"
  #Then I expect "Signed in successfully."

@javascript
Scenario: signup to the storyweaver page - without firstname
  Given I am on the Signup page
  When I fill in "user[email]" with "automation1299@yopmail.com"
  When I fill in "user[password]" with "automation@123"
  When I fill in "user[password_confirmation]" with "automation@123"
  When I select signup Button
  Then I expect "First name can't be blank, First name is too short (minimum is 2 characters)"

@javascript
Scenario: signup to the storyweaver page - without email
  Given I am on the Signup page
  When I fill in "user[first_name]" with "automation"
  When I fill in "user[password]" with "automation@123"
  When I fill in "user[password_confirmation]" with "automation@123"
  When I select signup Button
  Then I expect "Email can't be blank"

@javascript
Scenario: signup to the storyweaver page - without password
  Given I am on the Signup page
  When I fill in "user[first_name]" with "automation"
  When I fill in "user[email]" with "automation1299@yopmail.com"
  When I fill in "user[password_confirmation]" with "automation@123"
  When I select signup Button
  Then I expect "Password can't be blank"

@javascript
Scenario: signup to the storyweaver page - without confirmation password
  Given I am on the Signup page
  When I fill in "user[first_name]" with "automation"
  When I fill in "user[email]" with "automation1299@yopmail.com"
  When I fill in "user[password]" with "automation@123"
  When I select signup Button
  Then I expect "Password confirmation doesn't match Password"

@javascript
Scenario: signup to the storyweaver page - with invalid firstname
  Given I am on the Signup page
  When I fill in "user[first_name]" with "a"
  When I fill in "user[email]" with "automation1299@yopmail.com"
  When I fill in "user[password]" with "automation@123"
  When I fill in "user[password_confirmation]" with "automation@123"
  When I select signup Button
  Then I expect "First name is too short (minimum is 2 characters)"

@javascript
Scenario: signup to the storyWeaver page - with invalid email
  Given I am on the Signup page
  When I fill in "user[first_name]" with "automation"
  When I fill in "user[email]" with "automation1299@12"
  When I fill in "user[password]" with "automation@123"
  When I fill in "user[password_confirmation]" with "automation@123"
  When I select signup Button
  Then I expect "Email is invalid"

@javascript
Scenario: signup to the storyweaver page - with invalid password
  Given I am on the Signup page
  When I fill in "user[first_name]" with "automation"
  When I fill in "user[email]" with "automation1299@yopmail.com"
  When I fill in "user[password]" with "auto"
  When I fill in "user[password_confirmation]" with "auto"
  When I select signup Button
  Then I expect "Password is too short (minimum is 8 characters)"

@javascript
Scenario: signup to the storyweaver page - with invalid data
  Given I am on the Signup page
  When I fill in "user[first_name]" with ""
  When I fill in "user[email]" with ""
  When I fill in "user[password]" with ""
  When I fill in "user[password_confirmation]" with ""
  When I select signup Button
  Then I expect "First name can't be blank, First name is too short (minimum is 2 characters), Email can't be blank, Password can't be blank"

#Feature: Forgot password to storyweaver page

@javascript
Scenario: Forgot password link with valid email
  Given I am on the SignIn page
  Then I should see "Email"
  When I click link "Forgot your password?"
  Then I expect "Forgot your password?"
  When I fill in "user[email]" with "user@sample.com"
  When I press "Send me reset password instructions"
  Then I expect "You will receive an email with instructions on how to reset your password in a few minutes."

@javascript
Scenario: Forgot password link with empty email
  Given I am on the SignIn page
  When I click link "Forgot your password?"
  When I fill in "user[email]" with ""
  When I press "Send me reset password instructions"
  Then I expect "Email can't be blank"

@javascript
Scenario: Forgot password link with incorrect email
  Given I am on the SignIn page 
  When I click link "Forgot your password?"
  When I fill in "user[email]" with "user@abcd.com"
  When I press "Send me reset password instructions"
  Then I expect "Email not found"


#Feature: Resend confirmation password link

@javascript
Scenario: Re-send Forgot password link for confirmed email
  Given I am on the SignIn page
  When I click link "Didn't receive confirmation instructions?"
  Then I should see "Resend confirmation instructions"
  When I fill in "user[email]" with "user@sample.com"
  When I press "Resend confirmation instructions"
  Then I should see "Email was already confirmed, please try signing in"

@javascript
Scenario: Re-send Forgot password link for invalid email
  Given I am on the SignIn page
  When I click link "Didn't receive confirmation instructions?"
  When I fill in "user[email]" with "user@abcd.com"
  When I press "Resend confirmation instructions"
  Then I should see "Email not found"

@javascript
Scenario: Re-send Forgot password link for empty email
  Given I am on the SignIn page
  When I click link "Didn't receive confirmation instructions?"
  When I fill in "user[email]" with ""
  When I press "Resend confirmation instructions"
  Then I should see "Email can't be blank"

@javascript
Scenario: Re-send Forgot password link for unconfirmed email
  Given I am on the Signup page
  When I fill in "user[first_name]" with "automation"
  When I fill in "user[email]" with "automation1299@yopmail.com"
  When I fill in "user[password]" with "automation@123"
  When I fill in "user[password_confirmation]" with "automation@123"
  When I select signup Button
  #When I expect "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
  And I wait 5 seconds
  When I click link "Log In"
  When I click link "Didn't receive confirmation instructions?"
  When I fill in "user[email]" with "automation1299@yopmail.com"
  When I press "Resend confirmation instructions"
  Then I should see "You will receive an email with instructions for how to confirm your email address in a few minutes."
  Then I should see from and to address as "no-reply@prathambooks.org" and "automation1299@yopmail.com"
  And I wait 5 seconds
  When I follow the confirmation link in the confirmation email

@javascript
Scenario: Login to storyweaver page - validate user profile
  When I login as "user@sample.com" with "password"
  When I click at "Common Man"
  When I click link "Profile"
  Then I should see "Home"
  And I should see "Common Man"
  And I should see "Stories (0)"
  And I should see "Illustrations (0)"
  And I should see "Translations (0)"
  And I should see "Relevels (0)"
  And I should see "My Bookshelf (0)"
  And I should see "Media Mentions (0)"
