require 'spec_helper'

RSpec.describe "Api::V1::Stories::Requests", :type => :request do

  before(:each) do
    @user= FactoryGirl.create(:user)
  end
  let(:json) { JSON.parse(response.body) }

#SHOW
  context "GET Story Details" do
    let(:front_cover_page_template) {FactoryGirl.create(:front_cover_page_template,default: true,orientation: 'landscape')}
    let(:back_inner_cover_page_template) {FactoryGirl.create(:back_inner_cover_page_template,default: true,orientation: 'landscape')}
    let(:back_cover_page_template) {FactoryGirl.create(:back_cover_page_template,default: true,orientation: 'landscape')}
    it "should show the story details" do
      user1 = FactoryGirl.create(:user, :name => "Test user")
      person = FactoryGirl.create(:person_with_account, :user => user1)
      list= FactoryGirl.create(:list, user: @user)
      english = FactoryGirl.create( :language, :name => "english", :translated_name => "english")
      hindi = FactoryGirl.create( :language, :name => "hindi", :translated_name => "hindi")
      kannada = FactoryGirl.create( :language, :name => "kannada", :translated_name => "kannada")
      illustration = FactoryGirl.create(:illustration, :illustrators => [person])
      similar_story1 = FactoryGirl.create(:level_1_story,language: english, :tag_list => ["New tag"], :title => "Original Story", :authors => [user1], :status => Story.statuses[:published])
      front_cover_page = FactoryGirl.create(:front_cover_page, story: similar_story1, page_template: front_cover_page_template)
      generate_illustration_crop(front_cover_page, illustration)
      story_page_1 = FactoryGirl.create(:story_page)
      similar_story1.insert_page(story_page_1)
      back_inner_cover_page = FactoryGirl.create(:back_inner_cover_page, story: similar_story1, page_template: back_inner_cover_page_template)
      back_cover_page = FactoryGirl.create(:back_cover_page, story: similar_story1, page_template: back_cover_page_template)
      similar_story1.build_book
      similar_story1.save
      similar_story2 = FactoryGirl.create(:level_1_story,language: english,:status => Story.statuses[:published])
      similar_story3 = FactoryGirl.create(:level_3_story,language: hindi,:status => Story.statuses[:published])
      translated_story1 = similar_story1.new_derivation(FactoryGirl.attributes_for(:story, title: "Translated_story1", language_id: kannada.id).slice!(:id), similar_story1.authors.first, similar_story1.authors.first, "translated")
      translated_story1.save!
      relevelled_story1 = similar_story1.new_derivation(FactoryGirl.attributes_for(:story, title: "Relevelled_story1", language_id: similar_story1.language.id).slice!(:id), similar_story1.authors.first, similar_story1.authors.first, "revelled")
      relevelled_story1.save!
      list.stories << similar_story1
      Illustration.reindex
      Story.reindex
      List.reindex
      get "/api/v1/stories/#{similar_story1.id}"
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('name', 'id', 'language', 'level', 'slug', 'status', 'description', 'isTranslation', 'readsCount', 'likesCount', 'readingListMembershipCount', 'copyrightNotice', 'orientation', 'recommended', 'canEdit', 'publisher', 'publishedTime', 'donorName', 'contest', 'similarBooks', 'translations', 'coverImage', 'tags', 'downloadLinks', 'authors', 'originalStory', 'illustrators', 'lists', "availableForOfflineMode", "editorsPick", "externalLink", "googleFormDownloadLink", "isFlagged", "languageCount", "liked", "versionCount", "isRelevelled", "photographers", "downloadLimitReached")
      expect(response).to be_success
      expect_status(200)
    end
  end
#Filters
  context "GET Story details after filter" do
    it "should show the story details with filter" do
      story = FactoryGirl.create(:story, status: Story.statuses[:published], id: 1000)
      get "/api/v1/books/filters"
      expect_status(200)
      x = JSON.parse(response.body)
      expect(JSON.parse(response.body).keys).to contain_exactly('ok', 'data', 'sortOptions')
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('language', 'publisher', 'category', 'level')
      expect(JSON.parse(response.body)['data']['language'].keys).to contain_exactly('name', 'queryKey', 'sourceLanguage', 'targetLanguage', 'queryValues')
      expect(JSON.parse(response.body)['data']['language']['queryValues'][0].keys).to contain_exactly('name', 'queryValue')
      #Enable any one of the following filter once it's finalize"
      #expect_json_keys('data.organization', [:name, :queryKey, :queryValues])
      #expect_json_keys('data.publisher.queryValues', [:name, :queryValue])
      expect(JSON.parse(response.body)['data']['category'].keys).to contain_exactly('name', 'queryKey', 'queryValues')
      expect(JSON.parse(response.body)['data']['category']['queryValues'][0].keys).to contain_exactly('name', 'queryValue')
      expect(JSON.parse(response.body)['data']['level'].keys).to contain_exactly('name', 'queryKey', 'queryValues')
      expect(JSON.parse(response.body)['data']['level']['queryValues'][0].keys).to contain_exactly('name', 'queryValue', 'description')
      expect(JSON.parse(response.body)['sortOptions'][0].keys).to contain_exactly('name', 'queryValue')
      resp_name = x["sortOptions"].collect{|z| z["name"]}
      resp_name.should =~ ['Most Liked', 'Most Viewed', 'New Arrivals']
      resp_qvalue = x["sortOptions"].collect{|z| z["queryValue"]}
      resp_qvalue.should =~ ['likes', 'views', 'published_at']
      expect(response).to be_success
      expect_status(200)
    end
  end
end
