# == Schema Information
#
# Table name: stories
#
#  id                        :integer          not null, primary key
#  title                     :string(255)      not null
#  english_title             :string(255)
#  language_id               :integer          not null
#  reading_level             :integer          not null
#  status                    :integer          default(0), not null
#  synopsis                  :string(750)
#  publisher_id              :integer
#  created_at                :datetime
#  updated_at                :datetime
#  ancestry                  :string(255)
#  derivation_type           :string(255)
#  attribution_text          :text
#  recommended               :boolean          default(FALSE)
#  reads                     :integer          default(0)
#  flaggings_count           :integer
#  orientation               :string(255)
#  copy_right_year           :integer
#  cached_votes_total        :integer          default(0)
#  topic_id                  :integer
#  license_type              :string(255)      default("CC BY 4.0")
#  published_at              :datetime
#  downloads                 :integer          default(0)
#  high_resolution_downloads :integer          default(0)
#  epub_downloads            :integer          default(0)
#  chaild_created            :boolean          default(FALSE)
#  dedication                :string(255)
#  recommended_status        :integer
#  more_info                 :string(255)
#  donor_id                  :integer
#  copy_right_holder_id      :integer
#  credit_line               :string(255)
#  contest_id                :integer
#  editor_id                 :integer
#  editor_status             :boolean          default(FALSE)
#  user_title                :boolean          default(FALSE)
#  editor_recommended        :boolean          default(FALSE)
#  revision                  :integer
#  uploading                 :boolean          default(FALSE)
#  images_only               :integer          default(0)
#  text_only                 :integer          default(0)
#  started_translation_at    :datetime
#  is_autoTranslate          :boolean
#  publish_message           :text
#  download_message          :text
#  is_display_inline         :boolean          default(TRUE)
#  organization_id           :integer
#  recommendations           :string(255)
#  dummy_draft               :boolean          default(TRUE)
#
# Indexes
#
#  index_stories_on_ancestry                         (ancestry)
#  index_stories_on_cached_votes_total               (cached_votes_total)
#  index_stories_on_language_id_and_organization_id  (language_id,organization_id)
#

FactoryGirl.define do

  factory :story do
    sequence(:title) { |n| "Title#{n}" }
    sequence(:english_title) { |n| "English Title#{n}" }
    language
    authors {[FactoryGirl.create(:user)]}
    reading_level '1'
    status 'published'
    orientation 'landscape'
    attribution_text "This book has been published on StoryWeaver by rspec"
    sequence(:synopsis) { |n| "Synopsis #{n}" }
    copy_right_year Time.now.year
    categories {[FactoryGirl.create(:story_category)]}
    sequence(:organization_id) {|n| "organization_id #{n}"}
    published_at '2015-07-28 10:25:54'
  end  

  factory :story_with_publisher, class: Story do
    sequence(:title) { |n| "Title#{n}" }
    sequence(:english_title) { |n| "English Title#{n}" }
    language
    authors {[FactoryGirl.create(:user)]}
    reading_level '1'
    status 'published'
    orientation 'landscape'
    attribution_text "This book has been published on StoryWeaver by rspec"
    sequence(:synopsis) { |n| "Synopsis #{n}" }
    copy_right_year (1980..Time.now.year).to_a.sample
    categories {[FactoryGirl.create(:story_category)]}
    sequence(:organization_id) {|n| "organization_id #{n}"}
    published_at '2015-07-28 10:25:54'
  end

  factory :draft_story , class: Story do
    sequence(:title) { |n| "Title#{n}" }
    sequence(:english_title) { |n| "English Title#{n}" }
    language
    authors {[FactoryGirl.create(:user)]}
    reading_level '1'
    status 'draft'
    orientation 'landscape'
    attribution_text "This book has been published on StoryWeaver by rspec"
    categories {[FactoryGirl.create(:story_category)]}
    copy_right_year Time.now.year
    sequence(:synopsis) { |n| "Synopsis #{n}" }
    published_at '2015-07-28 10:25:54'
  end

  factory :level_1_story, class: Story do
    sequence(:title) { |n| "Level 1 Story Title" }
    sequence(:english_title) { |n| "English Title#{n}" }
    language
    authors {[FactoryGirl.create(:user)]}
    reading_level '1'
    status 'draft'
    orientation 'landscape'
    attribution_text "This book has been published on StoryWeaver by rspec"
    copy_right_year Time.now.year
    categories {[FactoryGirl.create(:story_category)]}
    synopsis "Synopsis"
    published_at '2015-07-28 10:25:54'
  end 
  
  factory :level_2_story , class: Story do
    sequence(:title) { |n| "Level 2 Story Title" }
    sequence(:english_title) { |n| "English Title#{n}" }
    language
    authors {[FactoryGirl.create(:user)]}
    reading_level '2'
    status 'draft'
    orientation 'landscape'
    attribution_text "This book has been published on StoryWeaver by rspec"
    copy_right_year Time.now.year
    categories {[FactoryGirl.create(:story_category)]}
    sequence(:synopsis) { |n| "Synopsis #{n}" }
    published_at '2015-07-28 10:25:54'
  end 
  
  factory :level_3_story , class: Story do
    sequence(:title) { |n| "Level 3 Story Title" }
    sequence(:english_title) { |n| "English Title#{n}" }
    language
    authors {[FactoryGirl.create(:user)]}
    reading_level '3'
    status 'draft'
    orientation 'landscape'
    attribution_text "This book has been published on StoryWeaver by rspec"
    copy_right_year Time.now.year
    categories {[FactoryGirl.create(:story_category)]}
    sequence(:synopsis) { |n| "Synopsis #{n}" }
    published_at '2015-07-28 10:25:54'
  end

  factory :level_4_story , class: Story do
    sequence(:title) { |n| "Level 4 Story Title" }
    sequence(:english_title) { |n| "English Title#{n}" }
    language
    authors {[FactoryGirl.create(:user)]}
    reading_level '4'
    status 'draft'
    orientation 'landscape'
    attribution_text "This book has been published on StoryWeaver by rspec"
    copy_right_year Time.now.year
    categories {[FactoryGirl.create(:story_category)]}
    sequence(:synopsis) { |n| "Synopsis #{n}" }
    published_at '2015-07-28 10:25:54'
  end
end
