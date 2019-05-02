And(/^I select Profile from UserDashBoard$/) do
  @sw.profile_dash_board.select_dashboard('Profile')
end

Then(/^I should not see any organization name under user section$/) do
  user_details = @sw.profile_dash_board.user_details 
  expect(user_details[:organization]).to eq Hash.new
end

Then(/^I should see organization name as "([^"]*)" under user section$/) do |org_name|
  user_details = @sw.profile_dash_board.user_details 
  expect(user_details[:organization].downcase).to eq org_name.downcase
end

When(/^I select "([^"]*)" tab in Profile dashboard$/) do |tab_name|
  @sw.profile_dash_board.select_tab(tab_name) 
end

Then(/^I should see newly created story in the list$/) do
  newly_created_story = @publish_story_title
  expect(@sw.profile_dash_board.all_stories_detail.first[:story_name]).to eq newly_created_story
end

Then(/^I should see the story added to my bookshelf$/) do
  story_title = @read_story_title # we are getting the story title from read page
  all_bookshelf_stories = @sw.profile_dash_board.get_bookshelf_stories
  expect(all_bookshelf_stories).to include story_title
end