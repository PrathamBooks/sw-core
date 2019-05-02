When /^I login to StoryWeaver with$/ do |table|
  visit('/')
  opts = table.rows_hash
  @sw.login_page.login_using(opts)
end

Then /^I should navigate to Home Page successfully$/ do
  current_page_url = @sw.base_page.parse_current_url
  expect(current_page_url.path).to eq "/"
end

Given /^I open StoryWeaver$/ do
  visit('/')
  @sw.base_page.close_popup
end

Then(/^I should navigate to login page$/) do
	expect(@sw.login_page.login_page?).to be true
	expect(@sw.login_page.has_field?('EMAIL')).to be true
	expect(@sw.login_page.has_field?('PASSWORD')).to be true
end
