Then (/^I should see review form as disabled$/) do
  expect(page).to have_xpath("//div[@id='review_form'][@class='disabled']")
end

Then (/^I should see review form as enabled$/) do
  expect(page).to have_xpath("//div[@id='review_form']")
end

When (/^(?:|I )click on first story to rate$/) do
  find(:xpath, "//*[@id='get_reviewer_language_stories']//table/tbody/tr[1]/td[1]/a").trigger('click')
end

When (/^(?:|I )select checkbox "([^"]*)" contains value "([^"]*)"$/) do |option, value|
  find(:xpath, "(//*[@id='#{option}'][@value='#{value}'])[1]").click
end

When (/^(?:|I )select radio button "([^"]*)" contains value "([^"]*)"$/) do |value, option|
  find(:xpath, "//*[@id='#{option}'][@name='#{value}']").click
end

When (/^I select rating star$/) do
  el = page.find(:xpath, "//div[@class='rating-container rating-gly-star']")
  el.click
  el1 = page.find(:xpath, ".//*[@id='new_reviewer_comment']/div[4]/div/div/div/div/div[2]/div")
  el1.click
end

# def computed_style(selector,prop)
# 	page.evaluate_script("window.getComputedStyle(document.querySelector('#{selector}')).#{prop}")
# end
