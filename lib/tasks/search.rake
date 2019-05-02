namespace :stories do
  desc "Reindex Stories"
  task :reindex => :environment do
    Story.reindex 
    puts 'Reindexed Stories'
  end
end

namespace :illustrations do
  desc "Reindex Illustrations"
  task :reindex => :environment do
    Illustration.reindex 
    puts 'Reindexed Illustrations'
  end
end

namespace :blog_posts do
  desc "Reindex Blog posts"
  task :reindex => :environment do
    BlogPost.reindex
    puts 'Reindexed Blog Posts'
  end
end

namespace :users do
  desc "Reindex Users"
  task :reindex => :environment do
    User.reindex
    puts 'Reindexed users'
  end
end
