namespace :stories do
  desc "Fix the titles that were left untranslated by Google"
  task :fix_auto_titles => :environment do
    translated_stories = Story.where(is_autoTranslate: true, status: Story.statuses[:draft])
    puts "Number of stories: #{translated_stories.size}"
    at_user = User.find_by first_name:"Working Draft"
    translated_stories.each do |s|
      if s.authors[0] == at_user
        if s.title == s.parent.title
          c_title = s.parent.title.downcase
          n_title = ApplicationController.helpers.translateText(c_title,s.language.name)
          n_title = n_title.split.map(&:capitalize).join(' ')
          puts "title: #{s.title}, new title: #{n_title}"
          s.title = n_title
          s.save
        end
      end
    end
  end
end
