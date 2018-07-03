require 'cucumber/rails'
#require 'capybara/poltergeist'
require 'cucumber/rspec/doubles'

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css
ENV["RAILS_ENV"] ||= 'test'

# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
     #DatabaseCleaner.strategy = :transaction
     #DatabaseCleaner.clean_with(:truncation)
     #DatabaseCleaner.start 
rescue NameError
    raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Delayed::Worker.delay_jobs = false

# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
Cucumber::Rails::Database.javascript_strategy = :truncation

#Capybara.javascript_driver = :poltergeist
#Capybara.default_driver = :poltergeist
#Capybara.default_driver = :selenium

Capybara.javascript_driver = :webkit
Capybara.default_driver = :webkit
Capybara.server_port = 3000

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
