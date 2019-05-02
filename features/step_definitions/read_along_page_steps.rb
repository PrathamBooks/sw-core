When(/^I navigate to Readalong Page$/) do
  @sw.base_page.navigate_to(SWCONSTANTS::READALONG)
  expect(@sw.read_along_page.read_along_page?).to be true
end

Then /^I should be Readalong Page$/ do
  expect(@sw.read_along_page.read_along_header?).to be true
end

And /^I choose first story in readalong page$/ do
  @read_along_story_title = @sw.read_along_page.get_first_story_title
end

And /^I get available story options for the story$/ do
  @read_along_first_story_details = @sw.read_along_page.story_details(@read_along_story_title)
end

Then /^I should see ReadAlong is available for the story card on hover over story$/ do
  expect(@read_along_first_story_details[:hover_actions][:readalong]).to be true
end

Then /^I click on first story in readalong page$/ do
  sleep 3
  @sw.read_along_page.select_first_story(@read_story_title)
  sleep 3
end

Then(/^I should see "([^"]*)" Filters in applied section of readalong page$/)do |filters|
  steps %{
    Then I Should see "#{filters}" filters in applied section
  }
end

And(/^I choose "([^"]*)" from quick view in read along page$/) do |action_name|
  @sw.read_along_page.more_quick_view(@read_along_story_title, action_name, false)
end

