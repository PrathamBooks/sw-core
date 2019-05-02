Then(/^I should be in image details page$/) do
  expect(@sw.image_details_page.image_details_page?).to be true
end

When(/^I get the image details$/) do
  @image_details = @sw.image_details_page.image_details
end

When(/^I like the image$/) do
  result = @sw.image_details_page.like_image
  p "Failed to like image" if result[:error]
  expect(result[:error]).to eq false
  expect(result[:status]).to eq 'ok'
  expect(result[:message]).to eq 'successful'
end

Then(/^I should see like count is incremented by "([^"]*)"$/) do |incr_count|
  incr_count = incr_count.to_i
  expect(@sw.image_details_page.like_count).to eq @image_details[:like_count]+incr_count
end

Then(/^I should see like count is incremented by "([^"]*)" for the illustration$/) do |incr_count|
  incr_count = incr_count.to_i
  expect(@sw.image_details_page.like_count).to eq @image_details[:like_count]+incr_count
end

Then(/^I should see view count is incremented by "([^"]*)" for the illustration$/) do |incr_view_count|
  incr_view_count = incr_view_count.to_i
  expect(@sw.image_details_page.view_count).to eq @image_details[:views]+incr_view_count
end

Then(/^I select create story from image details page$/) do
  @sw.image_details_page.create_story
end

When(/^I share the image through "([^"]*)"$/) do |share_to|
  @sw.image_details_page.share(to: share_to)
end

And(/^I report the image with$/) do |report_details|
  report_details = report_details.rows_hash
  reason = report_details.fetch(:reason){nil}
  reason_text = report_details.fetch(:text){nil}
  @sw.image_details_page.report(reason: reason, reason_text: reason_text)
end

And(/^I should see image as reported$/) do
  expect(@sw.image_page.reported?).to eq true
end
