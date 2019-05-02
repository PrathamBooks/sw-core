namespace :delayed_job do
  desc "Stop Delayed Job Worker"
  task :stop => :environment do
    system("cd #{Rails.root} && RAILS_ENV=#{Rails.env} bin/delayed_job stop >> log/delayed_rake_stop.log")
    puts 'Stopped delayed job worker'
  end
end
