Then (/^(?:|I )should see (\d+) stories$/) do |stories_count|
  expect(page).to have_xpath(".//div[@class='pb-filters-bar__status']//span[contains(text(),'#{stories_count}')]")
end

When (/^(?:|I )click "([^"]*)"$/) do |link_text|
  Illustration.reindex
  a = find(:xpath, "(//a[contains(text(),'#{link_text}')])[1]").trigger('click')
end

When (/^(?:|I )select "([^"]*)"$/) do |link_text|
  find(:xpath, "(//*[contains(text(),'#{link_text}')])[1]").trigger('click')
end

When (/^(?:|I )click on search button$/) do
  find(:xpath, "(//button[@type='submit'])[1]").click
end

Then (/^(?:|I )expect to see "([^"]*)"$/) do |css_path|
  if page.respond_to? :should
    expect(page).to have_css(css_path)
  else
    assert page.have_css?(:css)
  end
end

When (/^(?:|I )choose "([^"]*)"$/) do |option|
  find(:xpath, "//input[@value='#{option}']").click
end

When (/^I should see radio button "([^"]*)" as selected$/) do |radio_button_name|
  expect(find_field("#{radio_button_name}")).to be_checked
end

When (/^(?:|I )click on drop down button "([^"]*)"$/) do |button|
  find(:xpath, "//button[@title='#{button}']").click
end

When (/^(?:|I )click close button$/) do
  find(:xpath, "//*[contains(text(),'Cancel')]").click
end

When (/^(?:|I )click on "([^"]*)" icon in the side bar$/) do | icon |
  find(:xpath, "(//*[@class='#{icon}'])").click
end

When (/^(?:|I )click on read icon$/) do
  find(:xpath, "(//*[@class='btn-slide animation animated-item-3 ']/i)[1]").click
end

When (/^(?:|I )click on icon "([^"]*)"$/) do | icon |
  find(:xpath, "//a[@title='#{icon}']").click
end

When (/^(?:|I )click on "([^"]*)" icon in footer $/) do | icon |
  find(:xpath, "(//*[@class='fa fa-#{icon}'])[2]").click
end

Then (/^(?:|I )should see logged in user dropdown button$/) do
  button = find(:xpath, ".//*[@id='homepage_dropdown']/button")
  button_value = button.text
  if page.respond_to? :should
    expect(page).to have_content(button_value)
  else
    assert page.has_content?(button_value)
  end
end

When (/^(?:|I )should see social icon "([^"]*)"$/) do |icon_value|
  if page.respond_to? :should
    expect(page).to have_xpath("(//*[@id='social_container']/a/label[@class='#{icon_value}'])[1]")
  else
    assert page.have_xpath?(icon_value)
  end
end

When (/^I should see invisible elements "([^"]*)"$/) do |class_name|
  if page.respond_to? :should
    expect(page).to have_xpath("(.//*[@class='#{class_name}'])[1]")
  else
    assert page.have_xpath?(class_name)
  end
end

When (/^I should not see invisible elements "([^"]*)"$/) do |class_name|
  if page.respond_to? :should
    expect(page).to have_no_xpath("(.//*[@class='#{class_name}'])[1]")
  else
    assert page.have_xpath?(class_name)
  end
end

When (/^I close popup window$/) do
  find(:xpath, "//a[@class='pb-link pb-link--default pb-modal__close']").click
end

When (/^I click dots menu$/) do
  find(:xpath, "(//a[@class='pb-link pb-link--light pb-book-card__dropdown-link'])[1]").click
end
