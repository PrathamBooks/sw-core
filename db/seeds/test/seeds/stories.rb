def create_stories(stories: 1, category: get_story_category, language: nil, reading_level: nil,
    author: nil, story_title: nil, flaggings_count: nil, organization: nil,
    derivation_type: nil, status_text: "published", contest: false)

    (1..stories).each do|story|
      illustration = get_illustration
      author_record = author != nil ? author : get_author
      language_record = language != nil ? language : get_language
      reading_level_record = reading_level != nil ? reading_level : rand(4)
      title = story_title != nil ? story_title : "automation_story_#{story}"
      contest_id = contest != false ? create_contest().id : nil
      #organization_record = organization != nil ? organization : nil
      derivation_type_record = derivation_type != "nil" ? derivation_type : nil
      story = Story.create!(title: title, attribution_text: 'automation', language: language_record,
        english_title: "automation_testing_sample_#{story}",
        reading_level: reading_level_record, status: Story.statuses["#{status_text}"],
        copy_right_year: Time.now.year, authors: [author_record], contest_id: contest_id,
        synopsis: 'Its a sample story for testing', orientation: 'landscape',
        categories: [category],flaggings_count: flaggings_count, derivation_type: derivation_type_record)
      story.build_book(nil,true,illustration)
      front_cover = story.pages.first
      illustration.process_crop!(front_cover)
      story.organization = organization
      story.save!
      #StoriesController.new.make_story_static_files(story)
    end
    Story.reindex
end

def get_author
  author = rand(User.count)+1
  rand_record = User.find_by_id(author)
  return rand_record
end

def get_language
  language_id = rand(Language.count)+1
  rand_record = Language.find_by_id(language_id)
  return rand_record
end

def get_illustration
  illustration_id = rand(Illustration.count)+1
  rand_record = Illustration.find_by_id(illustration_id)
  return rand_record
end

def get_story_category
  story_category_id = rand(StoryCategory.count)+1
  rand_record = StoryCategory.find_by_id(story_category_id)
  return rand_record
end

def create_contest(name: "Test_contest", type: "Story")
  contest = Contest.create!(name: name, contest_type: type, start_date: Time.now, end_date: Time.now+1.day, tag_name: "Contest_tag")
  contest.save!
  contest
end

# create_stories(5)
