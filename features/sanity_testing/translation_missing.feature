Feature: To check Translation Missing across the tool

@translation
@javascript
@sanity
Scenario: Login to storyweaver page - valid email and password
  When I login to StoryWeaver with
  |	Email 		| user@sample.com |
  | Password 	| password | 
  And I navigate to Read Page
  Then I vaildate Translation missing is not available in all filters in Read Page
