require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "env"))
require File.expand_path(File.join(File.dirname(__FILE__), "../../", "config", "environment"))

Given /the following languages exist/ do |language_table|
  language_table.hashes.each do |language|
    language = Language.create(:name => language["name"], :can_transliterate => language["can_transliterate"], :script => language["script"])
  end
end

Given /the following illustrationcategory exist/ do |illustrationcategory_table|
  illustrationcategory_table.hashes.each do |illustrationcategory|
    illustrationcategory = IllustrationCategory.create(:name => illustrationcategory["name"])
  end
end

Given /the following illustrationstyle exist/ do |illustrationstyle_table|
  illustrationstyle_table.hashes.each do |illustrationstyle|
    illustrationstyle = IllustrationStyle.create(:name => illustrationstyle["name"])
  end
end

Given /the following storypagetemplate exist/ do |storypagetemplate_table|
  storypagetemplate_table.hashes.each do |storypagetemplate|
    storypagetemplate = StoryPageTemplate.create(:name => storypagetemplate["name"], 
      :default => storypagetemplate["default"], :orientation => storypagetemplate["orientation"], 
      :image_position => storypagetemplate["image_position"], 
      :content_position => storypagetemplate["content_position"], 
      :image_dimension => storypagetemplate["image_dimension"], 
      :content_dimension => storypagetemplate["content_dimension"])
  end
end

Given /the following frontcoverpagetemplate exist/ do |frontcoverpagetemplate_table|
  frontcoverpagetemplate_table.hashes.each do |frontcoverpagetemplate|
    frontcoverpagetemplate = FrontCoverPageTemplate.create(:name => frontcoverpagetemplate["name"], 
      :default => frontcoverpagetemplate["default"],
      :orientation=> frontcoverpagetemplate["orientation"], 
      :image_position => frontcoverpagetemplate["image_position"], 
      :content_position => frontcoverpagetemplate["content_position"], 
      :image_dimension => frontcoverpagetemplate["image_dimension"], 
      :content_dimension => frontcoverpagetemplate["content_dimension"])
  end
end

Given /the following backcoverpagetemplate exist/ do |backcoverpagetemplate_table|
  backcoverpagetemplate_table.hashes.each do |backcoverpagetemplate|
    backcoverpagetemplate = BackCoverPageTemplate.create(:name => backcoverpagetemplate["name"], :default => backcoverpagetemplate["default"],
      :orientation => backcoverpagetemplate["orientation"], :image_position => backcoverpagetemplate["image_position"], 
      :content_position => backcoverpagetemplate["content_position"], :image_dimension => backcoverpagetemplate["image_dimension"],
      :content_dimension => backcoverpagetemplate["content_dimension"])
  end
end

Given /the following backinnercoverpagetemplate exist/ do |backinnercoverpagetemplate_table|
  backinnercoverpagetemplate_table.hashes.each do |backinnercoverpagetemplate|
    backinnercoverpagetemplate = BackInnerCoverPageTemplate.create(:name => backinnercoverpagetemplate["name"],
     :default => backinnercoverpagetemplate["default"], :orientation => backinnercoverpagetemplate["orientation"], 
     :image_position => backinnercoverpagetemplate["image_position"], :content_position => backinnercoverpagetemplate["content_position"],
     :image_dimension => backinnercoverpagetemplate["image_dimension"], :content_dimension => backinnercoverpagetemplate["content_dimension"])
  end
end

Given /the following dedicationpagetemplate exist/ do |dedicationpagetemplate_table|
  dedicationpagetemplate_table.hashes.each do |dedicationpagetemplate|
    dedicationpagetemplate = DedicationPageTemplate.create(:name => dedicationpagetemplate["name"],
      :default => dedicationpagetemplate["default"],
      :orientation => dedicationpagetemplate["orientation"],
      :image_position => dedicationpagetemplate["image_position"],
      :content_position => dedicationpagetemplate["content_position"],
      :image_dimension => dedicationpagetemplate["image_dimension"],
      :content_dimension => dedicationpagetemplate["content_dimension"])
  end
end

Given /the following storycategory exist/ do |storycategory_table|
  storycategory_table.hashes.each do |storycategory|
    storycategory_table = StoryCategory.create(:name => storycategory["name"])
  end
end

Given /the following illustrations exist/ do |illustration_table|
  illustration_table.hashes.each do |illustrations|
    illustration_table = Illustration.create(:name => illustrations["name"],
      :image_file_name => illustrations["image_file_name"],
      :license_type => illustrations["license_type"],
      :copy_right_year => illustrations["copy_right_year"],
      :copy_right_holder_id => illustrations["copy_right_holder_id"],
      :organization_id => illustrations["organization_id"])
  end
end

When (/^I click on Create Story$/) do
  find(:xpath, "//input[@value='Create Story']").click
end

When (/^I click button "([^"]*)"$/) do |text|
  find(:xpath, "(//button[contains(text(),'#{text}')])[1]").click
end
When (/^I click on "([^"]*)" containing "([^"]*)"$/) do |id,text|
  find(:xpath, ".//*[@id='#{id}']//span[contains(text(),'#{text}')]").click
end

When (/^I click on category$/) do
  find(:xpath, "(//button[contains(text(),'None selected')])[1]").trigger('click')
end

When (/^I click on image style$/) do
  find(:xpath, ".//*[@id='new_illustration']/div[3]/div[3]/div[2]/div/div/div/button").click
end

When (/^(?:|I )click checkbox category$/) do
  find(:xpath, ".//*[@id='new_illustration']/div[3]/div[2]/div[2]/div/div/div/ul/li[1]/a/label/input").click
end

When (/^I click checkbox to choose story category$/) do
  sleep 5
  find(:xpath, ".//*[@id='publish_model']/div[2]/div[2]/div[2]/div/div/div/div/ul/li[1]/a/label").trigger('click')
end

When (/^(?:|I )click checkbox imagestyle$/) do
  find(:xpath, ".//*[@id='new_illustration']/div[3]/div[3]/div[2]/div/div/div/ul/li[1]/a/label/input").click
end

When (/^(?:|I )attach image "([^"]*)"$/) do |illustration|
  script = "$('#file-profile-upload').css({display: 'block'});"
  page.execute_script(script)
  image_file_name = Rails.root.to_s + "/illustrations/image_#{illustration}.jpg"
  attach_file('illustration[image]', image_file_name)
  Illustration.reindex
end

When (/^(?:|I )click on new arrivals$/) do
  find(:xpath, ".//*[@id='StorySortOptions']")
  Illustration.reindex
end

When (/^I select image as add to current page$/) do
  page.execute_script("$('.img-card-action-block.dead-center').show();");
  sleep 5
  page.find(:xpath, "(.//*[contains(text(),'add to current page')])[1]").click
  sleep 5
  page.find(:xpath, ".//*[@id='croppicModalObj']/div[2]/i[3]").click
end

When (/^I select image as save to favourites$/) do
  page.execute_script("$('.img-card-action-block').show();");
  sleep 5
  page.find(:xpath, "(.//*[contains(text(),'save to favourites')])[1]").click
  sleep 5
  expect(page).to have_content("remove from favourites")
end

When (/^I select image as remove from favourites$/) do
  page.execute_script("$('.img-card-action-block').show();");
  sleep 5
  page.find(:xpath, "(.//*[contains(text(),'remove from favourites')])[1]").click
  sleep 7
  expect(page).not_to have_content("save to favourites")
end

When (/^I select page "(\d+)"$/) do |num|
  page.find(:xpath, "(.//div[@class='illustration_container'])[#{num}]").trigger('click')
end

When (/^I select varnam text$/) do
  sleep 10
  expect(page).to have_content("STORY TITLE (In English)")
  sleep 5
  page.find(:xpath, "(.//*[@id='varnam_ime_suggestions']//li)[1]").trigger('click')
end

When (/^I select "([^"]*)" from the tour "([^"]*)"$/) do |link_text, dataid|
  page.find(:xpath, "//div[@data-id='#{dataid}']//a[contains(text(),'#{link_text}')]").trigger('click')
end
