require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "env"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "mailer_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "wait_for_ajax"))
require File.expand_path(File.join(File.dirname(__FILE__), "../../", "config", "environment"))

Given /the following users exist/ do |users_table|
  users_table.hashes.each do |user|
    user = User.new(:first_name => user["first_name"], :email => user["email"], :password => user["password"], :password_confirmation => user["password_confirmation"])
    user.skip_confirmation!
    user.save!
  end
end

When (/^I login as "([^"]*)" with "([^"]*)"$/) do |user_email, password|
  visit('/')
  click_link "Log In"
  fill_in('user_email', :with => user_email)
  fill_in('user[password]', :with => password)
  find(:xpath, "//input[@value='Log in']").click
  sleep 10
end

When (/^I login again as "([^"]*)" with "([^"]*)"$/) do |user_email, password|
  click_link "Log In"
  fill_in('user_email', :with => user_email)
  fill_in('user[password]', :with => password)
  find(:xpath, "//input[@value='Log in']").click
end

When (/^I login as "([^"]*)" with "([^"]*)" for hindi translation$/) do |user_email, password|
  visit('/')
  sleep 10
  #commented the below code as phone stories deactived
  #find(:xpath, "//a[@class='pb-link pb-link--default pb-modal__close']").trigger('click')
  #sleep 2
  page.execute_script "window.scrollBy(0,10000)"
  find(:xpath, "//div[@class='pb-select-field__input-wrapper']//select[@class='pb-select-field__input']").trigger('click')
  find(".pb-select-field__input").first(:option, "हिंदी").select_option
  sleep 2
  page.execute_script "window.scrollTo(0,0)"
  find(:xpath, "//span[contains(text(),'लॉग इन')]").trigger('click')
  fill_in('user_email', :with => user_email)
  fill_in('user[password]', :with => password)
  find(:xpath, "//input[@value='Log in']").click
end

Given (/^(?:|I )am on (.+)$/) do |page_name|
  visit path_to(page_name)
end

When (/^(?:|I )press "([^"]*)"$/) do |button|
  User.all.each do |u|
  end
  first(:button, button).trigger('click')
end

When (/^(?:|I )take screen shot for "([^"]*)"$/) do |image_name|
  page.save_screenshot(image_name, full: true)
end

When (/^(?:|I )follow "([^"]*)"$/) do |link|
  click_link(link)
end

When (/^(?:|I )click link "([^"]*)"$/) do |link|
  first(:link, link).trigger('click')
end

Then (/^(?:|I )should see button "([^"]*)"$/) do |link_text|
  expect(page).to have_xpath("//a[contains(text(),'#{link_text}')]")
end

Then (/^(?:|I )should see Modal Form$/) do
  expect(page).to have_xpath("//div[@id='newStoryForm']//div[@class='modal-body modal-body-app']")
end

Then (/^(?:|I )should see Login Modal Form$/) do
  expect(page).to have_xpath("//div[@id='loginForm']")
end

When (/^(?:|I )select download link option$/) do
  a = first(:css, '.download-link')
  a.click
  b = a["href"]
  driver.get(b)
end

When (/^I access the new tab$/) do
  page.driver.switch_to_window(page.driver.browser.window_handles.last)
end

When (/^I access the previous tab$/) do
  page.driver.browser.switch_to_window(page.driver.browser.window_handles.first)
end

When (/^I refresh the page$/) do
  page.evaluate_script('window.location.reload()')
end

When (/^I get the URL of current page$/) do
  url = URI.parse(current_url)
  puts url
end

When (/^I close the current tab$/) do
  page.execute_script("window.close()")
end

When (/^(?:|I )select Download Button$/) do
  find(:xpath, "(//a[3]/i)[3]").click
end

When (/^(?:|I )select signup Button$/) do
  find(:xpath, "//input[@value='Sign up']").click
end

When (/^(?:|I )clicked on Story link$/) do
  find(:xpath, ".//*[@id='profile-stories']/div//tr[1]/td[1]/a").click
end

When (/^I click on "([^"]*)"$/) do |element|
  first(:css, element).trigger('click')
end

When (/^I select checkbox "([^"]*)"$/) do |element|
  find(:css, "#{element}").set(true)
  #first(:css, element).trigger('click')
end

Then (/^(?:|I )click to close "([^"]*)"$/) do |text|
  find(:xpath, "(//span[contains(text(),'#{text}')]//a)[1]").click
end

When (/^(?:|I )click on share to "([^"]*)"$/) do |element|
  first(:css, ".ssb-icon.ssb-'#{element}'").click
end

When (/^(?:|I )fill in "([^"]*)" with "([^"]*)"$/) do |field, value|
  fill_in(field, :with => value)
end

When (/^(?:|I )fill in "([^"]*)" for "([^"]*)"$/) do |value, field|
  first(:css, field).set(value)
end

Then (/^(?:|I )should see "([^"]*)"$/) do |text|
  BlogPost.reindex
  if page.respond_to? :should
    expect(page).to have_content(text)
  else
    assert page.has_content?(text)
  end
end

Then (/^(?:|I )expect "([^"]*)"$/) do |text|
  User.all.each do |u|
  end
  if page.respond_to? :should
    expect(page).to have_content(text)
  else
    assert page.has_content?(text)
  end
end

Then (/^(?:|I )see "([^"]*)"$/) do |text|
  if page.respond_to? :should
    expect(page).to have_text(text)
  else
    assert page.has_text?(text)
  end
end

Then (/^I should see "([^"]*)" contains "([^"]*)"$/) do |field, value|
  if page.respond_to? :should
    expect(page).to have_field(field, with: value)
  else
    assert page.has_field(field, with: value)
  end
end

When (/^I wait (\d+) seconds?$/) do |seconds|
  sleep seconds.to_i
end

When (/^(?:|I )select "([^"]*)" from "([^"]*)"$/) do |value, field|
  #select(value, :from => field).select_option
  select "#{value}", from: "#{field}", :match => :first
end

When (/^(?:|I )select option from "([^"]*)" as "([^"]*)"$/) do |id, text|
  find(:xpath, "(.//*[@id='#{id}']//button[contains(text(),'#{text}')])[1]").trigger('click')
end

When (/^(?:|I )select option "([^"]*)" from "([^"]*)"$/) do |text, id|
  find(:xpath, ".//div[@id='#{id}']//a[contains(text(),'#{text}')]").trigger('click')
end

Then (/^(?:|I )should see "([^"]*)" from "([^"]*)"$/) do |text, id|
  a = page.find(:xpath, ".//*[@id='#{id}']//table/tbody/tr[1]")
  if a.respond_to? :should
    expect(a).to have_content(text)
  else
    assert a.has_content?(text)
  end
end

Then (/^(?:|I )should see heading as "([^"]*)" from "([^"]*)"$/) do |text, id|
  a = page.find(:xpath, ".//*[@id='#{id}']//table/thead/tr/th[1]")
  if a.respond_to? :should
    expect(a).to have_content(text)
  else
    assert a.has_content?(text)
  end
end

Then (/^I should see in translation drafts as "([^"]*)"$/) do |text|
  a = page.find(:xpath, "//table/tbody/tr[1]")
  if a.respond_to? :should
    expect(a).to have_content(text)
  else
    assert a.has_content?(text)
  end
end

Then (/^(?:|I )should see from and to address as "([^"]*)" and "([^"]*)"$/) do |from, to|
  from_addr = last_email.from[0]
  to_addr = last_email.to[0]
  expect(from_addr).to eq(from)
  expect(to_addr).to eq(to)
end

Then (/^I should not see "([^"]*)"$/) do |text_content|
  expect(page).to have_no_content(text_content)
end

Then (/^(?:|I )should see "([^"]*)" in "([^"]*)"$/) do |val, field|
  text_area = first(:css, field).text
  expect(text_area).to eq(val)
end

When (/^(?:|I )accept the download$/) do
  page.driver.browser.accept_confirm
end

Then (/^(?:|I )check my mail for assigned as "([^"]*)" reviewer email$/) do |lang|
  expect(last_email.body).to have_content("Thanks for agreeing to rate #{lang} stories on StoryWeaver.")
end

Then (/^(?:|I )check my mail for assigned as "([^"]*)" translator email$/) do |lang|
  expect(last_email.body).to have_content("Thank you for signing up to translate stories in #{lang} on StoryWeaver.")
end

When (/^(?:|I )click button "([^"]*)" with value "([^"]*)"$/) do |name, value|
  find(:xpath, "//*[@name='#{name}'][@value='#{value}']").trigger('click')
end

When (/^I click button "([^"]*)" for "([^"]*)"$/) do |value, id|
  find(:xpath, "//*[@id='#{id}']//input[@value='#{value}']").click
end

# Then (/^(?:|I )should see button "([^"]*)" with value "([^"]*)"$/) do |name, value|
#    find(:xpath, "//*[@name='#{name}'][@value='#{value}']")
# end

When (/^(?:|I )add image "([^"]*)" for organization$/) do |illustration|
  image_file_name = Rails.root.to_s + "/illustrations/image_#{illustration}.jpg"
  attach_file('org[logo]', image_file_name)
  find(:xpath, ".//*[@id='logo_form']/input[@value='Submit']").click
end

Then (/^(?:|I )should see value "([^"]*)" in "([^"]*)"$/) do |val, field|
  text_area = first(:css, field).value
  expect(text_area).to eq(val)
end

Then (/^(?:|I )should see "([^"]*)" in country$/) do |val|
  text_area = find(:css, '.btn.dropdown-toggle.selectpicker.btn-default')[:title]
  expect(text_area).to eq(val)
end

Then (/^(?:|I )download "(\d+)" "([^"]*)" stories$/) do |count, format|
  (1..count.to_i).each do|number|
    if (number%7.0) == 0.0
      find(:xpath, "(//*[contains(text(),'Load More')])").click
    end
    find(:xpath, "(//div[1]/div/div/div/a[3]/i)[#{number}]").click
    sleep 4
    find(:xpath, "(//a[contains(text(),'#{format}')])").click
    page.driver.browser.accept_confirm
    sleep 5
    Story.reindex
  end
end

When (/^(?:|I )fill in "([^"]*)" with number "([^"]*)"$/) do |field, value|
  fill_in(field, :with => value.to_i)
end

When (/^I Sign Out$/) do
  sign_out="$.ajax({type: 'delete', url: '/users/sign_out'});"
  page.execute_script(sign_out);
end

When (/^I should not see invalid translation$/) do
  validation = page.text.match(/\w{2,}\.(\w{2,}\-)*\w{2,}/)
  if page.respond_to? :should
    expect(validation).to eq(nil)
  else
    assert page.has_content?(validation)
  end
end
