TRANSLATION_MISSING = "Translation Missing found for ".freeze

When /^I navigate to Read Page$/ do
  @sw.base_page.navigate_to("Read")
  expect(@sw.read_page.read_page?).to be true
end

Then /^I vaildate Translation missing is not available in all filters in Read Page$/ do
  available_filters = @sw.read_page.get_filters
  available_filters.each do |filter_name|
    @sw.read_page.select_filter(filter_name)
    options = @sw.read_page.get_filter_options
    p options.join(',')
    raise (TRANSLATION_MISSING+"#{filter_name} in Read Page") if @sw.read_page.translation_missing?(options)
  end
end

When /^I apply the following filters in read page$/ do |filter_table|
  filter_hash = filter_table.rows_hash
  filter_hash.each do |filter_name, options|
    @sw.read_page.add_filter(filter_name, options)
  end
end

Then(/^I should see the "([^"]*)" story in the list$/) do |story_title|
  expect(@sw.read_page.all_stories).to include story_title
end

When /^I add the story to my bookshelf from read page$/ do
  @mybookshelf ||= []
  flag = @sw.story_details.story_actions('Add to My Bookshelf')
  @mybookshelf << @sw.story_details.story_title if !!flag
end

When /^I remove the story from my bookshelf from read page$/ do
  @removedbookshelf ||= []
  flag = @sw.story_details.story_actions('Delete from My Bookshelf')
  if !!flag
    title = @sw.story_details.story_title
    @removedbookshelf << title
    @mybookshelf -= title
  end
end

When /^I choose first story in read page$/ do
  @read_story_title = @sw.read_page.get_first_story_title
end

When(/^I click on first story$/) do
  sleep 3
  @sw.story_details.click_firststory(@read_story_title)
  sleep 3
end

When(/^I choose "([^"]*)" from quick view$/) do |action_name|
  @sw.read_page.more_quick_view(@read_story_title, action_name, false)
end

Then /^I should see story reader popup$/ do
  expect(@sw.story_read_popup.story_reader_popup?).to be true
end

Then /^I read the complete story$/ do
  @sw.story_read_popup.complete_story_with
end

And(/^I get the story details of first story$/) do
  @read_first_story_details = @sw.read_page.story_details(@read_story_title)
end

And /^I navigate to story details of first story$/ do
  sleep 5
  @sw.read_page.read_story(@read_story_title)
end

Then(/^I should see "([^"]*)" in more actions of quick view$/)do |action_name|
  expect(@sw.read_page.quick_view_actions(@read_story_title)).to include(action_name)
end

And(/^I click on quickview$/) do
  @sw.read_page.click_quick_view(@read_story_title)
end

And(/^I should see QuickView popup$/) do
  expect(@sw.read_page.quick_view_popup?).to be true
end

And(/^I select "([^"]*)" from quick view popup$/) do |action_name|
  @sw.read_page.quick_view_footer(action_name)
  sleep 5
end

And(/^I should see Log In popup$/) do
  expect(@sw.read_page.login_popup?).to be true
end

Then(/^I should see "([^"]*)" in Filters section of read page$/) do |filters_list|
 expect(@sw.read_page.get_filters).to eq filters_list.split(',')
end

Then(/^I should the all the sorty by filter options in the drop down$/) do
 actual_sort_by_options = @sw.read_page.get_sort_by_options
 expect(SWCONSTANTS::RP_SORTBYOPTIONS - actual_sort_by_options).to be_empty
end

And(/^I Validate the QuikView popup details with read page details$/) do
 quick_popup_details = @sw.read_page.quick_view_popup_details
 [:title, :views].each do |story_detail|
   expect(@read_first_story_details[story_detail]).to eq quick_popup_details[story_detail]
 end
end

Then(/^I Should see "([^"]*)" filters in applied section$/) do |filter_name|
 expect(@sw.read_page.filters_applied.map(&:downcase)).to include filter_name.downcase
end

Then(/^I Should see "([^"]*)" story in the read page list$/) do |story_title|
  expect(@sw.read_page.all_stories).to include story_title
end

When(/^I apply level "([^"]*)" under Level filter in read page$/) do |level|
  LEVELS = 'Levels'
  all_levels = @sw.read_page.get_filter_options(LEVELS)
  @sw.read_page.select_filter(LEVELS)
  @sw.read_page.add_filter(LEVELS, all_levels[level.to_i-1], true)
end

Then(/^I should be navigated to read page$/) do
  sleep 3
  expect(page.read_page.read_page?).to be true
end

Then(/^I apply sort filter with "([^"]*)"$/) do |filter_name|
  to_apply_filter = SWCONSTANTS::RP_SORTBYOPTIONS.find{ |filter| filter.downcase == filter_name.downcase }
  @sw.read_page.sort_by(to_apply_filter)
end
