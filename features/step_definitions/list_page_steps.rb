When(/^I navigate to List Page$/) do
  sleep 3
  @sw.base_page.navigate_to('Lists')
end

Then(/^I should see "([^"]*)" in Filters section of list page$/) do |filter|
 expect(@sw.list_page.get_filters).to_s == filter.to_s
end

Then(/^I should see following "([^"]*)" are present in Category section of list page$/) do |categorynames_list|
 expect(@sw.list_page.categories_list).to eq categorynames_list.split(',')
end

When(/^I apply the following filters in list page$/) do |filter_table|
  filter_hash = filter_table.rows_hash
  filter_hash.each do |filter_name, options|
    @sw.read_page.add_filter(filter_name, options)
  end
end

Then(/^I choose "([^"]*)" following list from list page$/) do |list_name|
   @sw.list_page.choose_listname(list_name)
end

Then(/^I should the all the sorty by filter options in the list drop down$/) do
  sort_by_options = @sw.list_page.get_listsort_by_options
  expect(sort_by_options).to eq SWCONSTANTS::LISTSORTOPTIONS
end

Then(/^I should be in list page$/) do
  expect(@sw.list_page.list_page?).to be true
end

Then(/^I get like count of that list$/) do
  @like_count = @sw.list_page.get_list_likes.to_i
end

Then(/^I get read count of the list$/) do
  @read_count = @sw.list_page.get_list_reads.to_i
end

When(/^I like a list in listdetails page$/) do
  @sw.list_page.like_list
end

Then(/^I validate like count "([^"]*)" incremented in listdetails page$/) do |actions|
 extra_count = actions == 'should' ? 1 : 0
 expect(@sw.list_page.get_list_likes) == (@like_count)+ extra_count
end

Then(/^I validate read count "([^"]*)" incremented in listdetails page$/) do |actions|
 extra_count = actions == 'should' ? 1 : 0
 expect(@sw.list_page.get_list_reads) == (@read_count)+ extra_count
end

When(/^I choose "([^"]*)" from listdetails page$/) do |action_name|
  @sw.list_page.list_actions(action_name)
end

Then(/^I validate listdetails page$/) do
  expect(@sw.list_page.list_details?).to be true
end

Then(/^I should see share options on listdetails page$/) do
  expect(@sw.list_page.list_popup_actions).to eq SWCONSTANTS::LISTSHAREACTIONS
end

Then(/^I choose a "([^"]*)" story from listdetails page$/) do |story_name|
  @sw.list_page.choose_story(story_name)
end

When(/^I choose "([^"]*)" publisher from listdetails page$/) do |author_name|
  @sw.list_page.choose_list_created(author_name)
end

Then(/^I Should see "([^"]*)" filters in applied section in listpage$/) do |filter_name|
  expect(@sw.read_page.filters_applied.map(&:downcase)).to include filter_name.downcase

end
And(/^I read complete story in listpage$/) do
  @sw.story_read_popup.completed_story_with
end

Then(/^I validate listfeedback form$/) do
  expect(@sw.list_page.get_mandatory_fileds_listfeedbakform).to eq SWCONSTANTS::LISTMANDATORYFIELDS
end

And(/^I read the complete story in list details page$/) do
  @sw.story_read_popup.completed_story_with
end

Then(/^I should see listfeedback form$/) do
  expect(@sw.list_page.list_feedback?).to be true
end

Then(/^I validate feedback response$/) do
  expect(@sw.list_page.validation_feedback).to be true
end

And(/^I select listfeedback form$/) do
  @sw.list_page.choose_list_popup
end
And(/^I fill and submit the list feedback form$/) do
  @sw.list_page.fill_sheet
end

When(/^I "([^"]*)" from storyweaver$/) do |actions|
  @sw.user_dash_board.select_dashboard(actions)
  sleep 5
end

Then(/^I validate organization details page$/) do
  expect(@sw.list_page.organization_page?).to be true
end

Given /^I open listfeedback form$/ do
  visit(SWCONSTANTS:: LISTFEEDBACKURL)
end