def clean_up(content)
  cleaned_content = content.gsub("&nbsp;", " ").gsub("\n", " ")
  cleaned_content = cleaned_content.gsub("</p>", "\n") #add newlines at paragraphs
  # remove html tags
  cleaned_content = ActionView::Base.full_sanitizer.sanitize(CGI.unescapeHTML(cleaned_content))
  # above may leave empty spaces before and after newlines, remove them
  cleaned_content = cleaned_content.gsub(/\s*\n\s*/, "\n")
  # replace multiple newlines with one, and remove new line from beginning
  cleaned_content = cleaned_content.squeeze("\n ").gsub(/^\n/,'')
  cleaned_content
end

namespace :stories do
  desc "Generate a CSV file with the original and translated texts"
  task :diff_auto_titles, [:language, :csv_file] => :environment do |t, args|
    language = Language.find_by_name(args[:language])
    translated_stories = Story.where(is_autoTranslate: true, status: Story.statuses[:published], language: language)
    puts "Number of stories: #{translated_stories.size}"
    CSV.open(args[:csv_file], "w") do |c_obj|
      translated_stories.each do |s|
        s.story_pages.each do |p|
          tp = GoogleTranslatedVersion.where(page: p)[0]
          if tp
            row = []
            row << clean_up(p.content)
            row << clean_up(tp.google_translated_content)
            c_obj << row
          end
        end
      end
    end
  end
end
