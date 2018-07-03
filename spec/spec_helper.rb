RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :deletion : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    Capybara.reset_sessions!
    DatabaseCleaner.clean
    FactoryGirl.reload
  end
end

def generate_illustration_crop(page, illustration=nil)
  illustration = illustration||FactoryGirl.create(:illustration)
  illustration_crop = illustration.process_crop!(page)
  illustration_crop.illustration = illustration
  illustration_crop.save!
  illustration_crop
end

def update_smart_crop_details(front_cover_page_crop, illustration, page)
  illustration.process_crop_background!(front_cover_page_crop, page)
end

def create_story(illustration: nil, story_title: "Full Story", reads: 5, language: nil)
  user = FactoryGirl.create(:user, :name => "Test user")
  language = language ? language : FactoryGirl.create(:english)
  @story = FactoryGirl.create(:story, :title => story_title, language: language, :tag_list => ["New tag"], :authors => [user], :status => Story.statuses[:published], editor_recommended: true, recommended_status: 0)
  @front_cover_page_template = FactoryGirl.create(:front_cover_page_template,default: true,orientation: 'landscape')
  @front_cover_page = FactoryGirl.create(:front_cover_page, story: @story, page_template: @front_cover_page_template)
  front_cover_page_illustration = illustration ? illustration : FactoryGirl.create(:illustration)
  front_cover_page_crop = generate_illustration_crop(@front_cover_page, front_cover_page_illustration)
  update_smart_crop_details(front_cover_page_crop, front_cover_page_illustration, @front_cover_page)
  story_page_1 = FactoryGirl.create(:story_page, :story => @story)
  @story.insert_page(story_page_1)
  back_inner_cover_page_template = FactoryGirl.create(:back_inner_cover_page_template,default: true,orientation: 'landscape')
  back_inner_cover_page = FactoryGirl.create(:back_inner_cover_page, story: @story, page_template: back_inner_cover_page_template)
  back_cover_page_template = FactoryGirl.create(:back_cover_page_template,default: true,orientation: 'landscape')
  back_cover_page = FactoryGirl.create(:back_cover_page, story: @story, page_template: back_cover_page_template)
  @story.build_book
  @story.save!
  @story.reads = reads
  Illustration.reindex
  Story.reindex
  @story
end

module Paperclip
  DUMMY_WIDTH  = '100'
  DUMMY_HEIGHT = '100'
  def self.run cmd, arguments = "", interpolation_values = {}, local_options = {}
    case cmd
    when "identify"
      return "#{DUMMY_WIDTH}x#{DUMMY_HEIGHT}"
    when "convert"
      return
    else
      super
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

class Paperclip::Attachment
  def post_process
  end
end
