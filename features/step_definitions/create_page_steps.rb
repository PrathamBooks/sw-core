When(/^I navigate to Create Page$/) do
  sleep 3
  @sw.base_page.navigate_to('Create')
end

Then(/^I should see create popup$/) do
  sleep 2
  expect(@sw.create_page.create_page?).to be true
end

And(/^I Validate the avaliable fields in the create story popup$/) do
  expect(@sw.create_page.create_popup_options?(SWCONSTANTS::CP_AVALIABLE_OPTIONS)).to be true
end

When(/^I choose cancel in create story popup$/) do
  @sw.create_page.create_pop_cancel
end

And(/^I fill the create story popup with default$/) do
  @create_story_details = @sw.create_page.create_book_with
end

And(/^I open image drawer$/) do
  @sw.create_page.open_image_drawer
end

And(/^I close image drawer$/) do
  @sw.create_page.close_image_drawer
end

And(/^I add the first image to my favourites$/) do
  @sw.create_page.open_image_drawer unless @sw.create_page.send(:image_popup?)
  @image_favourite_list = @sw.create_page.add_first_image_to_favourites
end

And(/^I click on help in create page$/) do
  @sw.create_page.select_help
end

Then(/^I validate the platform navigates me through all the actions available in the create page$/) do
  @sw.create_page.validate_tour_help
end

Then(/^I should see a delete validation popup$/) do
  error_details = @sw.create_page.send(:delete_page_validation)
  expect(error_details[:title]).to eq SWCONSTANTS::ATTENTIONREQUIRED
  expect(error_details[:message]).to eq SWCONSTANTS::CANNTREMOVEPAGE
end

And(/^I add images to the story$/) do
  sleep 5
  @sw.create_page.add_content_to_page
end

And(/^I add "([^"]*)" pages to the story$/) do |pages_toadd|
  @sw.create_page.add_pages(pages_toadd.to_i)
  @create_story_pages = @sw.create_page.send(:total_pages_count)
end

And(/^I get the total no.of pages avaliable for the story$/) do
  @create_story_pages = @sw.create_page.send(:total_pages_count)
end

And(/^I delete a page from the story$/) do
  @intial_pages_count = @sw.create_page.send(:total_pages_count)
  @sw.create_page.delete_page
end

And(/^I delete the last page of the story$/) do
  @sw.create_page.delete_page(confirmation: false)
end

And(/^I change the title of the story to "([^"]*)" through edit book information$/) do |updated_title|
  @sw.create_page.edit_book
  sleep 2
  @sw.create_page.change_title_inedit(updated_title)
  @updated_create_story_title = updated_title
  @old_create_story_title = @create_story_details[:title]
  @create_story_details[:title] = @updated_create_story_title
end

Then(/^I validate the updated title in story create page$/) do
  expect(@create_story_details[:title].downcase).to eq @sw.create_page.get_title_create_page.downcase
end

And(/^I publish the story$/) do
  @sw.create_page.publish_story
  @publish_story_title = @create_story_details[:title]
  sleep 5
end

When(/^I get the title of the story$/) do
  @create_story_title = @sw.create_page.get_title_create_page
end

Then(/^I validate newly created story is present first in read page$/) do
  expect(@sw.read_page.get_first_story_title).to eq @create_story_title
end

When(/^I publish the story without title$/) do
 @sw.create_page.publish_story({publish: {story_title: :skip}})
  sleep 2
end

Then(/^I should see error regarding title in publish popup$/) do
  expect(@sw.create_page.flash_error?).to eq true
  expect(@sw.create_page.flash_error).to eq SWCONSTANTS::TITLEERROR
end

When(/^I navigate to publish pop$/) do
  @sw.create_page.navigate_to_publish_popup
end

Then(/^I validate the fields present in publish popup for content manager$/) do
  sleep 2
  expect(@sw.create_page.get_mandatory_publish_popup_fields).to match_array SWCONSTANTS::PUBLISHPOPUPCMOPTIONS
end

Then(/^I validate the fields present in publish popup for normal user$/) do
  sleep 2
  expect(@sw.create_page.get_mandatory_publish_popup_fields).to match_array SWCONSTANTS::PUBLISHPOPUPNORMALUSEROPTIONS
end

When(/^I add '(\d+)' pages to the story$/) do |page_count|
  sleep 2
  @intial_pages_count = @sw.create_page.send(:total_pages_count)
  @sw.create_page.add_pages(page_count)
  @total_no_of_pages = @sw.create_page.send(:total_pages_count)
end

Then(/^I should be able to preview the story$/) do
  pages_hash = @sw.create_page.preview_story
  expect(pages_hash[:pages_count]).to eq @sw.create_page.send(:total_pages_count)
end

Then(/^I remove the image from my favourites$/) do
  @sw.create_page.remove_image_from_favourites
end

Then(/^I should see zero images in my favourite list$/) do
  expect(@sw.create_page.check_favourites[:image_count]).to eq 0
end

Then(/^I should see updated favourite list$/) do
  image_hash = @sw.create_page.check_favourites
  expect(image_hash[:images].map{|image| image[:image_name]}).to include @image_favourite_list
end

Then(/^I Validate total pages got incremented by '(\d+)'$/) do |count|
  sleep 2
  expect(@sw.create_page.send(:total_pages_count)).to eq @intial_pages_count+count.to_i
end

Then(/^I Validate total pages got decremented by '(\d+)'$/) do |count|
  sleep 2
  expect(@sw.create_page.send(:total_pages_count)).to eq @intial_pages_count-count.to_i
end

Then(/^I choose upload image$/) do
  click_link 'upload image'
end

Then(/^I fill fields present in editorupload popup$/) do
  @sw.create_page.fill_illustration_popup() 
end

Then(/^I uploaded an illustration$/) do
  @sw.create_page.illustration_publish
end

Then(/^I validate the fields present in editorupload popup for content manager$/) do
  expect(@sw.create_page.get_mandatory_editorimage_popup_fields).to eq SWCONSTANTS::EDITORILLUSTRATIONPUBLISHERUSER
end

Then(/^I validate the fields present in editorupload popup for normal user$/) do
  expect(@sw.create_page.get_mandatory_editorimage_popup_fields).to eq SWCONSTANTS::EDITORILLUSTRATIONNORMALUSER
end

When(/^I draft the story$/) do
  @draft_story_title = @sw.create_page.get_title_create_page
  @sw.create_page.save_story
end