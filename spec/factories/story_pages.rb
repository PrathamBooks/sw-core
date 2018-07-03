FactoryGirl.define do
  factory :story_page do
    page_template {FactoryGirl.create(:story_page_template)}
    story
    sequence(:content) { |n| "Content #{n}" }
  end
end
