def rails_defined?
  defined? ::Rails
end

And(/^I create one illustration for "([^"]*)" with title "([^"]*)" with Publisher "([^"]*)", Category "([^"]*)" and Style "([^"]*)"$/) do |user_email, image_title, publisher, category, style|
  next unless rails_defined?
  steps %{
  When I create one illustration for "#{user_email}" with title "#{image_title}"
  }
  illus = Illustration.find_by_name(image_title)
  if !publisher.empty?
    illus.organization = Organization.find_by_organization_name(publisher)
  end
  if !category.empty?
    category = IllustrationCategory.find_by_name(category)
    illus.categories << category unless illus.categories.include? category
  end
  if !style.empty?
    _style = IllustrationStyle.find_by_name(style)
    illus.styles << _style unless illus.styles.include? _style
  end
  illus.save
  Illustration.reindex
end

And(/^I disable the list feedback popup for "([^"]*)"$/) do |user_email|
  user = User.find_by_email(user_email)
  user_popup = UserPopup.new
  user_popup.user = user
  user_popup.name = 'ListModal'
  user_popup.save
end

When(/^I create one story with title "([^"]*)" with lanuguage "([^"]*)", with category "([^"]*)" as "([^"]*)", with reading level "([^"]*)", with author email as "([^"]*)", with status as "([^"]*)"$/) do |story_title, lang, category_type, category, reading_level, author_email, story_status|
  next unless rails_defined?
  new_story = Story.find_or_create_by!(title: story_title) do |story|
    story.language = Language.find_or_create_by(name: lang)
    story.categories << StoryCategory.find_or_create_by!(name: category)
    story.is_audio = true if category == SWCONSTANTS::READALONG
    story.reading_level = Story::READING_LEVELS[reading_level]
    story.authors << User.find_or_create_by(email: author_email)
    story.status = Story.statuses[story_status.to_sym]
    story.orientation = 'landscape'
    story.copy_right_year = Time.now.year
    story.synopsis = "Automation Trigger"
    story.published_at = Time.now
    story.audio_status = "audio_published"
  end
  illustration = Illustration.take(1).first
  new_story.build_book(nil, true, illustration)
  front_cover = new_story.pages.first
  illustration.process_crop!(front_cover)
  new_story.save!
  new_story.reindex
end
