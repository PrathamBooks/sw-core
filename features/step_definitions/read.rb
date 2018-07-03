Then (/^(?:|I )should see count of stories found$/) do
  expect(page).to have_xpath(".//*[@id='query_holder']/span[1]")
  find(:xpath, "(.//*[@id='query_holder']//span)[2]").text
  find(:xpath, ".//*[@id='query_holder']/span[1]").text
end

Then (/^(?:|I )should see story read count as "([^"]*)"$/) do |count|
  find(:xpath, "//div[@class='pb-stat pb-stat--m pb-stat--icon-default']//span[contains(text(),'#{count}')]")
end

Then (/^(?:|I )should see image$/) do
  find(:xpath, "//*[@id='selected_page']/div[1]/img")
end

When (/^I click at "([^"]*)"$/) do |link_text|
  find(:xpath, "(//span[contains(text(), '#{link_text}')])[1]").trigger('click')
end

When (/^(?:|I )create one illustration for "([^"]*)" with title "([^"]*)"$/) do |email, title|
  user = User.find_by_email(email)
  person = Person.create!(user_id: user.id, first_name: user.first_name, last_name: user.last_name)
  create_illustrations({illustrations_count: 1, name: title, person: person})
end

When (/^(?:|I )create one story with status as "([^"]*)" and story title as "([^"]*)" for the user "([^"]*)" and contest presence "([^"]*)"$/) do |status, title, email, contest|
  user = User.find_by_email(email)
  presence = contest == "false" ? false : true
  create_stories({stories: 1, status_text: status, story_title: title, author: user, contest: presence})
end
When (/^(?:|I )create "([^"]*)" stories with "([^"]*)" and "([^"]*)" and "([^"]*)" by "([^"]*)" with "([^"]*)" and "([^"]*)" and with "([^"]*)"$/) do |number_of_stories, category, language, reading_level, author, title, flaggings_count, organization|
  language_record = Language.find_by_name(language)
  author = User.find_by_email(author)
  category_record = StoryCategory.find_by_name(category)
  organization = Organization.find_by_email(organization)
  create_stories({stories: "#{number_of_stories}".to_i, category: category_record, language: language_record, reading_level: "#{reading_level}".to_i, author: author, story_title: title, flaggings_count: flaggings_count, organization: organization})
end

When (/^(?:|I )create "([^"]*)" stories with "([^"]*)" and "([^"]*)" and "([^"]*)" by "([^"]*)" with "([^"]*)" and "([^"]*)" and with org "([^"]*)"$/) do |number_of_stories, category, language, reading_level, author, title, flaggings_count, organization|
  language_record = Language.find_by_name(language)
  author = User.find_by_email(author)
  category_record = StoryCategory.find_by_name(category)
  organization = Organization.find_by_email(organization)
  create_stories({stories: "#{number_of_stories}".to_i, category: category_record, language: language_record, reading_level: "#{reading_level}".to_i, author: author, story_title: title, flaggings_count: flaggings_count, organization: organization})
end

When (/^(?:|I )create "([^"]*)" stories with "([^"]*)" and "([^"]*)" and "([^"]*)" by "([^"]*)" with "([^"]*)"$/) do |number_of_stories, category, language, reading_level, author, title|
  language_record = Language.find_by_name(language)
  author = User.find_by_email(author)
  category_record = StoryCategory.find_by_name(category)
  create_stories({stories: "#{number_of_stories}".to_i, category: category_record, language: language_record, reading_level: "#{reading_level}".to_i, author: author, story_title: title})
end

When (/^(?:|I )create "([^"]*)" stories with "([^"]*)" and "([^"]*)" and "([^"]*)" by "([^"]*)" with "([^"]*)" and "([^"]*)"$/) do |number_of_stories, category, language, reading_level, author, title, derivation_type|
  language_record = Language.find_by_name(language)
  author = User.find_by_email(author)
  category_record = StoryCategory.find_by_name(category)
  create_stories({stories: "#{number_of_stories}".to_i, category: category_record, language: language_record, reading_level: "#{reading_level}".to_i, author: author, story_title: title, derivation_type: derivation_type})
end

When (/^I should see read completed as "([^"]*)"$/) do |completed|
  story = StoryRead.find(1)
  read_status = (story.is_completed).to_s
  expect(read_status).to eq(completed)
end

When (/^I should see story records as "([^"]*)"$/) do |count|
  story_count = (StoryRead.count).to_s
  expect(story_count).to eq(count)
end
