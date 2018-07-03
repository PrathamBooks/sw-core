begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  DatabaseCleaner[:active_record].strategy = :truncation
  rescue NameError
  	raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before do |scenario|
	DatabaseCleaner.clean_with :truncation
	DatabaseCleaner.start
  # Rails.cache.clear
	load "#{Rails.root}/db/seeds/test/seeds/init.rb" 
	load "#{Rails.root}/db/seeds/test/seeds/users.rb" 
  load "#{Rails.root}/db/seeds/test/seeds/illustrations.rb"
  load "#{Rails.root}/db/seeds/test/seeds/stories.rb"
end

require 'fileutils'

After do |scenario|
  DatabaseCleaner.clean
  file_path = "#{Rails.root}/public/spec/test_files/illustration_crops"
  FileUtils.rm_rf(file_path)
  file_path = "#{Rails.root}/public/spec/test_files/illustrations"
  FileUtils.rm_rf(file_path)
  Story.reindex
end
