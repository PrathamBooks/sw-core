When(/^I navigate to user dash\-board through url$/) do
  @sw.base_page.force_url(SWCONSTANTS::PROFILE)
end

When(/^I select DashBoard$/) do
  sleep 5
  @sw.dash_board.select_dashboard
end

When(/^I select "([^"]*)" tab under Dashboard$/) do |dash_board_name|
  @sw.dash_board.goto_dashboard_tab(dash_board_name)
end

When(/^I change my password from "([^"]*)" to "([^"]*)"$/) do |old_password, new_password|
  @sw.dash_board.update_password_to(old_password: old_password, new_password: new_password)
end

When(/^I logout from the tool$/) do
  @sw.user_dash_board.logout_tool
end

Then(/^I should navigate to profile dashboard successfully$/) do
  expect(@sw.base_page.parse_current_url.path).to eq '/'+SWCONSTANTS::PROFILE
end

When(/^I update the following details of the user$/) do |user_details|
  options = user_details.rows_hash
  @sw.dash_board.update_my_details(options)
end

Then(/^I should see newly published stories in the dashboard list$/) do
  expect(@sw.dash_board.all_story_titles).to include @publish_story_title
end

Then(/^I should see newly drafted stories in the dashboard list$/) do
  expect(@sw.dash_board.all_story_titles).to include @draft_story_title
end

When(/^I delete the story from the list in the draft tab of dashboard$/) do
  @sw.dash_board.select_action_for(story_name: @draft_story_title, action_name: SWCONSTANTS::DELETE)
  confrm_popup_details = @sw.dash_board.confirmation_pop_up(true)
  expect(confrm_popup_details[:message].downcase).to include @draft_story_title.downcase
  expect(@sw.base_page.flash_message[:message]).to eq SWCONSTANTS::FALSHDRAFTDELETED
end

When(/^I shouldnot see newly drafted stories in the dashboard list$/) do
  expect(@sw.dash_board.all_story_titles).not_to include @draft_story_title
end

When(/^I edit the newly created story from the list in dashboard$/) do
  @sw.dash_board.select_action_for(story_name: @create_story_details[:title], action_name: SWCONSTANTS::EDIT)
end

Then(/^I should see the updated details of the user$/) do |user_details|
  user_details = user_details.rows_hash
  current_details = @sw.dash_board.my_details_data
  user_details.each do |attribute, value|
    attribute_key = attribute.downcase.gsub(' ','_').to_sym
    present_value = current_details[attribute_key]
    expect(present_value).to eq value
  end
end

And(/^I edit the newly created story from the published list$/) do
  Capybara.page.current_window.resize_to(1600, 1600)
  @sw.dash_board.open_story_new_tab(story_name: @create_story_details[:title])
end

And(/^I become an organisational user$/) do |table|
  @sw.dash_board.become_an_organisational_user
  @sw.dash_board.fill_org_form(table.rows_hash)
end
