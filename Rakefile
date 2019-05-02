# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'jasmine'
require 'spinach'
require 'rake/packagetask'
require 'rake/file_list'

Rails.application.load_tasks

task :default => ["spec", "jasmine:ci"]
task :ft => :spinach

Rake::PackageTask.new("spp", "0.0.1") do |p|
  p.need_tar = true
  file_exclusion_list = ['features', 'log', 'pkg', 'spec', 'tmp']
  all_files = FileList['./**/**']
  file_exclusion_list.each{|f| all_files=all_files.exclude('./' + f).exclude('./' + f + '/**/**')}
  p.package_files.include(all_files)
end
