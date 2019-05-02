namespace :stories do
  desc "Auto translate stories using Google APIs"
  task :auto_translate, [:lang, :nstories] => :environment do |t, args|
    l = Language.find_by_name(args[:lang])
    organization_names = ["StoryWeaver", "Book Dash", "Pratham Books", "African Storybook Initiative", "Ms Moochie", "Sub-Saharan Publishers"]
    organizations = Organization.where(organization_name: organization_names)
    nstories = args[:nstories].to_i
    puts "Translating #{nstories} stories to #{l.name}"
    english = Language.find_by_name("English")
    stories = Story.where(language: english, status: Story.statuses[:published]).where(organization:organizations).reorder(reads: :desc)
    puts "Found #{stories.size} candidate stories"
    selected_stories = []
    stories.each do |s|
      children = s.children
      found_translation = false
      children.each do |c|
        if c.language == l && c.derivation_type == "translated"
           if c.is_autoTranslate
             found_translation = true
             puts "#{s.title}: Found auto translation"
             break
           end
           if c.organization != nil
             found_translation = true
             puts "#{s.title}: Found organization translation, #{c.to_param}"
             break
           end
           if c.ratings.size > 0 && c.ratings[0].user_rating == 5
             found_translation = true
             puts "#{s.title}: Found 5 star translation"
             break
           end
        end
      end
      next if found_translation

      found_css = false
      r = /<style>/
      s.pages.each do |p|
        if(p.content != nil)
          matched = p.content.match(r)
          if(matched != nil)
            found_css = true
            puts "#{s.title}: Found css"
            break
          end
        end
      end
      next if found_css

      selected_stories << s
    end
    puts "Found #{selected_stories.size} stories without relevant translations"
    selected_stories[0..nstories-1].each do |s|
      puts "Trying to translate #{s.to_param}"
      t = s.auto_translate(l.id) rescue next
      puts "Translated #{s.to_param}, new translation #{t.to_param}"
      sleep(10)
    end
  end
end
