
When(/^I navigate to Image Page$/) do
  @sw.image_page.image_page
  sleep 5
end

Then(/^I should see "([^"]*)" in Filters section of image page$/) do |filter_names|
  filter_names = filter_names.split(',').map(&:downcase)
  expect(@sw.image_page.get_filters.map(&:downcase)).to match_array(filter_names)
end

Then(/^I Should see "([^"]*)" illustration in the image page list$/) do |illus_name|
  expect(@sw.image_page.all_illus_title).to include illus_name
end

Then(/^I should see all the sortby filter options in the drop down$/) do
  expect(@sw.image_page.get_sort_by_options).to match_array(["Relevance", "New Arrivals", "Most Viewed", "Most Liked"])
end

When(/^I select upload image$/) do
  @sw.image_page.select_upload_image
end

Then(/^LogIn popup should show up$/) do
  popup_details = @sw.image_page.popup_content
  expect(popup_details[:title]).to eq "Log In"
  expect(popup_details[:body]).to eq 'Please log in to upload an Illustration.' 
end

When(/^I fill the fields with following details$/) do |options|
  options = options.rows_hash
  @upload_image_details = @sw.image_page.fill_upload_form(options)
end

When(/^I upload the image successfully$/) do
  @sw.image_page.accept_terms_and_use
  status = @sw.image_page.upload_to_sw
  expect(status).to eq true
end

Then(/^I should see newly uploaded illustration in the list$/) do
  all_illustrations = @sw.profile_dash_board.all_illustrations_detail.map{|ele| ele[:image_name]}
  expect(all_illustrations).to include @upload_image_details[:title]
end

When(/^I select first image$/) do
  sleep 5
  @sw.image_page.select_first_image
end

When(/^I fill the image upload fields with following details$/) do |options|
  new_options = options.rows_hash
  new_options['browse'] = @sw.base_page.complete_file_path(new_options.delete('ImageType')) if (new_options.has_key?'ImageType')
  @upload_image_details = @sw.image_page.fill_upload_form(new_options)
end

Then(/^I should see error message regarding Image upload$/) do |messages|
  messages = messages.rows_hash
  error_details = @sw.image_page.validation_error_details
  expect(error_details[:title]).to eq 'Validation error!'
  expect(error_details[:message].start_with? messages['Message']).to eq true
end

When(/^I choose download Multiple Images$/) do
  sleep 2
  expect(@sw.image_page.select_download_multiple_image).to eq true
end

Then(/^I should see "([^"]*)" in the download option list$/) do |download_options|
  download_options = download_options.split(',').map(&:strip) if download_options.is_a? String
  expect(download_options - @sw.image_page.avaliable_download_options).to be_empty
end

Then(/^I should see validation message for download limit$/) do
  message = @sw.image_page.slim_pop_up_notification_text
  expect(message).to eq 'You can download only 10 images'
end

And(/^I should see image as reported$/) do
  expect(@sw.image_page.reported?).to eq true
end
