namespace :illustrations do
  desc "Upload illustrations to cloud"
  task :upload => :environment do
    puts 'Started uploading illustrations to cloud'
    Illustration.upload_illustrations_to_cloud
    puts 'Ended uploading illustrations to cloud'
    puts 'Started uploading illustration crops to cloud'
    IllustrationCrop.upload_illustration_crops_to_cloud
    puts 'Ended uploading illustration crops to cloud'
    puts 'Started removing illustrations from local storage'
    Illustration.remove_illustrations_from_local_storage
    puts 'Ended removing illustrations from local storage'
    puts 'Started removing illustration_crops from local storage'
    IllustrationCrop.remove_illustration_crops_from_local_storage
    puts 'Ended removing illustration_crops from local storage'
  end
end