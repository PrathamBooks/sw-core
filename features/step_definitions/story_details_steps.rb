Then /^I should be navigated to story details page$/ do
  expect(@sw.story_details.story_details?).to be true
end

Then /^I validate the details of the story with read page story card details$/ do
  read_story_details = @read_first_story_details
  @storydetails_details = @sw.story_details.story_details
  [:language, :level, :recommended, :views, :title].each do |config|
    expect(@storydetails_details[config]).to eq read_story_details[config]
  end
end

Then (/^I should see "([^"]*)" in story details page$/) do |action_name|
  expect(@sw.story_details.has_action?(action_name)).to be true
end

Then(/^I edit the story from story details page$/) do
  @sw.story_details.edit_story
end

Then(/^I like a story in storydetails page$/) do
  @sw.story_details.like_story
end

Then(/^I choose "([^"]*)" story in read page$/) do |story_name|
  @sw.story_details.click_firststory(story_name)
  sleep 5
end

Then(/^I get like count of that story$/) do
  @like_count = @sw.story_details.get_likes.to_i
end

Then(/^I get read count of that story$/) do
  @story_count = @sw.story_details.get_views_count.to_i
end

Then(/I validate story count "([^"]*)" incremented in storydetails/) do |actions|
  extra_count = actions == 'should' ? 1 : 0
  expect(@sw.story_details.get_views_count) == (@story_count)+extra_count
end

When(/^I validate like count "([^"]*)" incremented in storydetails page$/) do |actions|
  extra_count = actions == 'should' ? 1 : 0
  expect(@sw.story_details.get_likes) == (@like_count)+extra_count
end

When(/^I choose "([^"]*)" from storydetails page$/) do |action_name|
  @sw.story_details.story_actions(action_name)
end

Then(/^I should see Log In and signup popup$/) do
  expect(@sw.story_details.login_signup_popup).to eq SWCONSTANTS::LOGINSIGNUPPOP
end

Then(/^I should navigated to translator editor page$/) do
  expect(@sw.story_details.translate_detail?).to be true
end

Then(/^I read a story from story_details page$/) do
  @sw.story_details.read_story
end

Then(/^I read the complete story with smiley rating "([^"]*)"$/) do |action_name|
  @sw.story_read_popup.complete_story_with(action_name)
end

Then(/^I choose "([^"]*)" a story from nextread suggestions$/) do |action_name|
  @sw.story_read_popup.complete_story_with(false, action_name)
end

Then(/^I should see more actions popup on storydetails page$/) do
  expect(@sw.story_details.story_popup_actions).to eq SWCONSTANTS::MOREPOPUP
end

Then(/^I validate the fields present in more popup for content manager$/) do
  expect(@sw.story_details.story_popup_actions).to eq SWCONSTANTS::CONTENTMOREPOPUP
end
Then(/^I validate the fields present in more popup for normal user$/) do
  expect(@sw.story_details.story_popup_actions).to eq SWCONSTANTS::NORMALMOREPOPUP
end

Then(/^I should see share options on storydetails page$/) do
  expect(@sw.story_details.story_popup_actions).to eq SWCONSTANTS:: SHAREPOPUP
end

And(/^I reported story with "([^"]*)" following reason$/) do |reason|
  @sw.story_details.report_filter(reason)
end

And /^I should see ReadAlong option along with Read$/ do
  expect(@sw.story_details.has_action?(SWCONSTANTS::READSTORY)).to be true
  expect(@sw.story_details.has_action?(SWCONSTANTS::READALONG)).to be true
end
