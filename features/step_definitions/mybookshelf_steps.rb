When(/^I edit stories in my bookshelf$/) do
  @sw.mybookshelf_page.list_edit
end

Then(/^I perform "([^"]*)" action for this story "([^"]*)" in my bookshelf page$/) do |actions, story_name|
  @storyname = story_name
  @sw.mybookshelf_page.list_story_edit(story_name,actions)
end

And(/^I fill "([^"]*)" story description$/) do |description|
  @use = description
  @sw.mybookshelf_page.fill_story_description(description)
end

Then(/^I validate how to use description in my bookshelf$/) do
  expect(@sw.mybookshelf_page.validate_list_stortedit(@storyname)).to eq (@use)
end

Then(/^I validate deleted story in my bookshelf$/) do
  result = (@sw.mybookshelf_page.get_stories_list).include?(@storyname)
  expect(result).to be false
end

Then(/^I validate list description$/) do
  expect(@sw.mybookshelf_page.list_description_validation).to eq (@list_text)
end

Then(/^I saved edited changes in my bookshelf$/) do
   @sw.mybookshelf_page.list_edit_updation("Save changes")
  sleep 3
end

When(/^I select "([^"]*)" list from profile page/) do |list_name|
  @sw.mybookshelf_page.select_mybookshelf_list(list_name)
end

Then(/^I select "([^"]*)" from deletepopup in my bookshelf page$/) do |actions|
  @sw.mybookshelf_page.delete(actions)
  sleep 5
end

And(/^I get the position of the "([^"]*)" story in my bookshelf page$/) do |story_name|
  @book_name = story_name
  @position_count = @sw.mybookshelf_page.list_story_position(story_name)
end

When(/^I validate position of particular storyin listdetails page$/) do 
  expect(@sw.mybookshelf_page.list_story_position(@book_name)) != @position_count
end

And(/^I fill list description with "([^"]*)" content$/) do |message|
  @list_text = message
  @sw.mybookshelf_page.fill_list_description(message) 
end