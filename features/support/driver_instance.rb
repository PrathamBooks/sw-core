allowed_browsers = ['webkit', 'firefox', 'chrome']
@browser = ENV['browser'] || 'webkit'
raise "Browser Instance not supported" unless allowed_browsers.include? @browser

case @browser
	when 'webkit' then
		Capybara.javascript_driver = :webkit
		Capybara.default_driver = :webkit
		Capybara.register_driver :webkit do |app|
		  options = {
		        :js_errors => false,
		        :timeout => 120,
		        :debug => false,
		        :phantomjs_options => ['--proxy-type=none', '--load-images=yes', '--ignore-ssl-errors=true', '--disk-cache=false'],
		        :inspector => true,
		        :window_size => [1400,900],
		  }
		  Capybara::Webkit::Driver.new(app, options)
		end

	when 'firefox' then
		require_relative '../patches/firefox_session'
		Capybara.register_driver :selenium do |app|
		  profile = Selenium::WebDriver::Firefox::Profile.new
		  profile.secure_ssl = false
		  profile.assume_untrusted_certificate_issuer = false
  		profile['browser.secure_ssl'] = false
		  profile['browser.download.dir'] = $ProjectFolderPath+"/features/downloads" rescue "/features/downloads"
		  profile['browser.download.folderList'] = 2
		  profile['browser.download.panel.shown'] = false
		  profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/zip, application/pdf, application/vnd.ms-excel, text/csv, application/x-msexcel, application/excel, application/x-excel, text/html, text/plain, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
		  Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile, :marionette => true)
		end
		Capybara.default_driver = :selenium
		window = Capybara.current_session.driver.browser.manage.window
		window.resize_to(1280, 800)

	when 'chrome' then
		Capybara.default_driver = :selenium
		Capybara.javascript_driver = :chrome
		Capybara.register_driver :chrome do |app|
			Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
				'chromeOptions' => {
				'args' => [ "--window-size=1920,1080" ],
				'prefs' => {
				'download.default_directory' => File.expand_path("#{ProjectFolderPath}/features/downloads"),
				'download.prompt_for_download' => false
				}}))
		end

end