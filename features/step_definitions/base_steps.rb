When(/^I Move to latest window session$/) do
  sleep 5
  Capybara.switch_to_window Capybara.current_session.windows.last
  p "**************** #{page.current_url} ****************"
end

When(/^I Move to old window session$/) do
  sleep 5
  all_windows = Capybara.current_session.windows
  all_windows.each do |new_window|
    p new_window.current_url
  end
  Capybara.switch_to_window Capybara.current_session.windows.first
  p "**************** #{page.current_url} ****************"
end

And(/^I move to new tab "([^"]*)"$/) do |tab_name|
  window = []
  Capybara.current_session.windows.each do |new_window|
    Capybara.switch_to_window new_window
    window = new_window if @sw.base_page.parse_current_url.host.include? tab_name
  end
  raise "Window with name #{tab_name} not found" if window.is_a? Array
  Capybara.switch_to_window window
end

Then(/^I get story weaver session details$/) do
  all_windows = Capybara.current_session.windows
  (@sw_window = all_windows.first and next )if all_windows.size == 1
  current_window =  Capybara.current_window
  Capybara.current_session.windows.each do |new_window|
    Capybara.switch_to_window new_window
    current_host = @sw.base_page.parse_current_url.host
    @sw_window = new_window if ['storyweaver.org', 'dev.pbees.party', '127.0.0.1'].include? current_host
  end
  Capybara.switch_to_window current_window
end

And(/^I navigate to external "([^"]*)" tab$/) do |tab_name|
  tab_name =tab_name.downcase
  all_windows = Capybara.current_session.windows
  _window = []
  sleep_amount = all_windows.count
  sleep sleep_amount
  Capybara.current_session.windows.each do |new_window|
    Capybara.switch_to_window new_window
    sleep sleep_amount
    current_host = @sw.base_page.parse_current_url.host
    _window = new_window if current_host.include? tab_name
  end
  raise "External tab with name {tab_name}, NOT FOUND!" if _window.is_a? Array
  Capybara.switch_to_window _window
end


And(/^I navigate back to storyweaver tab$/) do
  Capybara.switch_to_window @sw_window
end

Then(/^I verify it is external "([^"]*)" page$/) do |window_name|
  expect(@sw.base_page.parse_current_url.host.downcase).to include window_name.downcase
end