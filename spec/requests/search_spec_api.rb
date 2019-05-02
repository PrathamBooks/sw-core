require "spec_helper"
require "rails_helper"

RSpec.describe "Api::V1::Search::Requests", :type => :request do

  before(:each) do
    @user= FactoryGirl.create(:user)
  end
  let(:json) { JSON.parse(response.body) }
  let(:front_cover_page_template) {FactoryGirl.create(:front_cover_page_template,default: true,orientation: 'landscape')}

#Books_for_translation
  context "GET books for translation details" do
    it "should show books for translation details" do
      org1 = FactoryGirl.create(:org_publisher, id: 1)
      @pub1= FactoryGirl.create(:publisher_org, organization_id: org1.id)
      story = FactoryGirl.create(:story, title: "Editor_Story", :status => Story.statuses[:published], :organization_id => org1.id)
      User.reindex
      Organization.reindex
      Story.reindex
      get "/api/v1/books-for-translation", format: :json
      expect_status(200)
      expect_json(ok: true)
      expect(JSON.parse(response.body).keys).to contain_exactly("ok", "metadata", "data")
      expect(JSON.parse(response.body)['metadata'].keys).to contain_exactly("hits", "perPage", "page", "totalPages")
      expect(JSON.parse(response.body)['data'][0].keys).to contain_exactly("id", "title", "language", "level", "slug", "recommended", "coverImage", "authors","availableForOfflineMode", "contest", "description", "editorsPick", "illustrators", "likesCount", "publisher", "readsCount" )
      expect(JSON.parse(response.body)['data'][0]['coverImage'].keys).to contain_exactly("aspectRatio", "cropCoords", "sizes")
      expect_json('data.0.title', 'Editor_Story')
      expect(JSON.parse(response.body)['data'][0]['slug']).to end_with('-english-title1')
    end
  end

#illustrations-search
  context "GET illustrations search details" do
    it "should show illustrations search details" do
      illustration = FactoryGirl.create(:illustration)
      get "/api/v1/illustrations-search"
      expect_status(200)
      expect_json(ok: true)
      expect(JSON.parse(response.body).keys).to contain_exactly("ok", "metadata", "data")
      expect(JSON.parse(response.body)['metadata'].keys).to contain_exactly("hits", "perPage", "page", "totalPages")
      expect(JSON.parse(response.body)['data'][0].keys).to contain_exactly("count", "id", "illustrators", "imageUrls", "likesCount", "publisher", "readsCount", "slug", "title")
      expect(JSON.parse(response.body)['data'][0]['imageUrls'][0].keys).to contain_exactly("aspectRatio", "cropCoords", "sizes")
      expect(JSON.parse(response.body)['data'][0]['imageUrls'][0]['sizes'][0].keys).to contain_exactly("height", "width", "url")
      expect(JSON.parse(response.body)['data'][0]['imageUrls'][0]['sizes'][0]['url']).to start_with('/spec/test_files/illustrations/')
    end
  end
#books-search
  context "GET books search details" do
    it "should show books search details" do
      @story_list = FactoryGirl.create_list(:story, 5, status: Story.statuses[:published], editor_recommended: true)
      @story_list.each do |story|
        @front_cover_page = FactoryGirl.create(:front_cover_page, story: story, page_template: front_cover_page_template)
        generate_illustration_crop(@front_cover_page)
      end
      Story.reindex
      expect(Story.all.count).to eq(5)
      get "/api/v1/books-search"
      expect_status(200)
      expect_json(ok: true)
      expect(JSON.parse(response.body).keys).to contain_exactly("ok", "metadata", "data")
      expect(JSON.parse(response.body)['metadata'].keys).to contain_exactly("hits", "perPage", "page", "totalPages")
      expect(JSON.parse(response.body)['data'][0].keys).to contain_exactly("id", "title", "slug", "language", "level", "recommended", "coverImage", "authors", "availableForOfflineMode", "contest", "description", "editorsPick", "illustrators", "likesCount", "publisher", "readsCount")
      expect(JSON.parse(response.body)['data'][0]['coverImage'].keys).to contain_exactly("aspectRatio", "cropCoords", "sizes")
      expect(JSON.parse(response.body)['data'][0]['coverImage']['sizes'][0].keys).to contain_exactly("height", "width", "url")
      expect_json('data.0.coverImage', cropCoords: {})
      expect(JSON.parse(response.body)['data'][0]['coverImage']['sizes'][0]['url']).to start_with('/spec/test_files/illustration_crops/')
      expect(JSON.parse(response.body)['data'][0]['authors'][0].keys).to contain_exactly("slug", "name")
      expect_status(200)
    end
  end
  #people-search
  context "GET people search details" do
    it "should show all the results" do
      user_1 = FactoryGirl.create(:user, :first_name => "Pratham", :last_name => "books")
      story_1 = FactoryGirl.create(:story, :authors => [user_1], status: Story.statuses[:published])
      user_2 = FactoryGirl.create(:content_manager, :first_name => "Content", :last_name => "manager")
      person_2 = FactoryGirl.create(:person_with_account, :user => user_2)
      illustration_1 = FactoryGirl.create(:illustration, :illustrators => [person_2])
      user_3 = FactoryGirl.create(:publisher_org, :first_name => "Publisher", :last_name => "Test")
      person_3 = FactoryGirl.create(:person_with_account, :user => user_3)
      illustration_3 = FactoryGirl.create(:illustration, :illustrators => [person_3])
      story_2 = FactoryGirl.create(:story, :authors => [user_3], status: Story.statuses[:published])
      user_4 = FactoryGirl.create(:admin, :first_name => "Admin", :last_name => "Test")
      User.reindex
      Story.reindex
      get "/api/v1/people-search"
      expect_status(200)
      expect_json(ok: true)
      expect(JSON.parse(response.body).keys).to contain_exactly('ok', 'metadata', 'data')
      expect(JSON.parse(response.body)['metadata'].keys).to contain_exactly('hits', 'perPage', 'page', 'totalPages')
      expect(JSON.parse(response.body)['data'].count).to eq(3)
      expect(JSON.parse(response.body)['data'][0].keys).to contain_exactly('id', 'name', 'slug', 'type', 'profileImage')
      expect_json('data.0.name', 'Pratham books')
      expect(JSON.parse(response.body)['data'][0]['slug']).to end_with('-pratham-books')
      expect_json('data.0.type', 'user')
      expect_json('data.0.profileImage', 'assets/profile_image.svg')
    end
    it "should show people search details with valid query" do
      user_1 = FactoryGirl.create(:user, :first_name => "Pratham", :last_name => "books")
      story_1 = FactoryGirl.create(:story, :authors => [user_1], status: Story.statuses[:published], editor_recommended: true)
      user_2 = FactoryGirl.create(:content_manager, :first_name => "Content", :last_name => "manager")
      story_2 = FactoryGirl.create(:story, :authors => [user_2], status: Story.statuses[:published], editor_recommended: true)
      user_3 = FactoryGirl.create(:publisher_org, :first_name => "Publisher", :last_name => "Test")
      story_3 = FactoryGirl.create(:story, :authors => [user_3], status: Story.statuses[:published], editor_recommended: true)
      user_4 = FactoryGirl.create(:admin, :first_name => "Admin", :last_name => "Test")
      story_4 = FactoryGirl.create(:story, :authors => [user_4], status: Story.statuses[:published], editor_recommended: true)
      user_5 = FactoryGirl.create(:reviewer, :first_name => "Reviewer", :last_name => "Test")
      User.reindex
      Story.reindex
      get "/api/v1/people-search", :query => 'manager'
      expect_status(200)
      expect_json(ok: true)
      expect(JSON.parse(response.body).keys).to contain_exactly('ok', 'metadata', 'data')
      expect(JSON.parse(response.body)['metadata'].keys).to contain_exactly('hits', 'perPage', 'page', 'totalPages')
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0].keys).to contain_exactly('id', 'name', 'slug', 'type', 'profileImage')
      expect_json('data.0.name', 'Content manager')
      expect(JSON.parse(response.body)['data'][0]['slug']).to end_with('-content-manager')
      expect_json('data.0.type', 'user')
      expect_json('data.0.profileImage', 'assets/profile_image.svg')
    end
    it "should show people search details with invalid query" do
      user_1 = FactoryGirl.create(:user, :first_name => "Pratham", :last_name => "books")
      story_1 = FactoryGirl.create(:story, :authors => [user_1], status: Story.statuses[:published], editor_recommended: true)
      user_2 = FactoryGirl.create(:content_manager, :first_name => "Content", :last_name => "manager")
      story_2 = FactoryGirl.create(:story, :authors => [user_2], status: Story.statuses[:published], editor_recommended: true)
      user_3 = FactoryGirl.create(:publisher_org, :first_name => "Publisher", :last_name => "Test")
      story_3 = FactoryGirl.create(:story, :authors => [user_3], status: Story.statuses[:published], editor_recommended: true)
      user_4 = FactoryGirl.create(:admin, :first_name => "Admin", :last_name => "Test")
      story_4 = FactoryGirl.create(:story, :authors => [user_4], status: Story.statuses[:published], editor_recommended: true)
      user_5 = FactoryGirl.create(:reviewer, :first_name => "Reviewer", :last_name => "Test")
      User.reindex
      Story.reindex
      get "/api/v1/people-search", :query => 'man ager'
      expect_status(200)
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect(JSON.parse(response.body).keys).to contain_exactly('ok', 'metadata', 'data')
      expect(JSON.parse(response.body)['metadata'].keys).to contain_exactly('hits', 'perPage', 'page', 'totalPages')
    end
    # it "should show all people search details if it is empty query" do
    #   user_1 = FactoryGirl.create(:user, :first_name => "Pratham", :last_name => "books")
    #   story_1 = FactoryGirl.create(:story, :authors => [user_1], status: Story.statuses[:published], editor_recommended: true)
    #   user_2 = FactoryGirl.create(:content_manager, :first_name => "Content", :last_name => "manager")
    #   story_2 = FactoryGirl.create(:story, :authors => [user_2], status: Story.statuses[:published], editor_recommended: true)
    #   user_3 = FactoryGirl.create(:publisher_org, :first_name => "Publisher", :last_name => "Test")
    #   story_3 = FactoryGirl.create(:story, :authors => [user_3], status: Story.statuses[:published], editor_recommended: true)
    #   user_4 = FactoryGirl.create(:admin, :first_name => "Admin", :last_name => "Test")
    #   story_4 = FactoryGirl.create(:story, :authors => [user_4], status: Story.statuses[:published], editor_recommended: true)
    #   user_5 = FactoryGirl.create(:reviewer, :first_name => "Reviewer", :last_name => "Test")
    #   User.reindex
    #   Story.reindex
    #   get "/api/v1/people-search", :query => '' #need to fix the code - if the query is empty then it has to show all the results
    #   expect_status(200)
    #   expect_json(ok: true)
    #   expect(JSON.parse(response.body)['data'].count).to eq(0)
    #   expect(JSON.parse(response.body).keys).to contain_exactly('ok', 'metadata', 'data')
    #   expect(JSON.parse(response.body)['metadata'].keys).to contain_exactly('hits', 'perPage', 'page', 'totalPages')
    # end
  end
  context "GET category banner details" do
    it "should show category banner details" do
      cat_1 = FactoryGirl.create(:story_category, :name => "Activity Books")
      cat_2 = FactoryGirl.create(:story_category, :name => "Backdrop")
      cat_3 = FactoryGirl.create(:story_category, :name => "Buildings")
      cat_4 = FactoryGirl.create(:story_category, :name => "Math")
      get "/api/v1/category-banner", :name => "Math"
      expect_status(200)
      expect_json(ok: true)
      expect(JSON.parse(response.body).keys).to contain_exactly('ok', 'data')
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('name', 'slug', 'bannerImageUrl')
      expect_json('data.name', 'Math')
      expect(JSON.parse(response.body)['data']['slug']).to end_with('-math')
      expect_json('data.bannerImageUrl', '/assets/original/missing.png')
    end
    #code change required
    # it "should show error message for invalid category banner" do
    #   cat_1 = FactoryGirl.create(:story_category, :name => "Activity Books")
    #   cat_2 = FactoryGirl.create(:story_category, :name => "Backdrop")
    #   cat_3 = FactoryGirl.create(:story_category, :name => "Buildings")
    #   cat_4 = FactoryGirl.create(:story_category, :name => "Math")
    #   get "/api/v1/category-banner", :name => "Activity"
    #   expect_status(200)
    #   expect_json(ok: true)
    #   expect(JSON.parse(response.body).keys).to contain_exactly('ok', 'data')
    #   expect(JSON.parse(response.body)['data'].keys).to contain_exactly('name', 'slug', 'bannerImageUrl')
    #   expect_json('data.name', 'Math')
    #   expect(JSON.parse(response.body)['data']['slug']).to end_with('-math')
    #   expect_json('data.bannerImageUrl', '/assets/original/missing.png')
    # end
    # it "should show error message for empty category banner" do
    #   cat_1 = FactoryGirl.create(:story_category, :name => "Activity Books")
    #   cat_2 = FactoryGirl.create(:story_category, :name => "Backdrop")
    #   cat_3 = FactoryGirl.create(:story_category, :name => "Buildings")
    #   cat_4 = FactoryGirl.create(:story_category, :name => "Math")
    #   get "/api/v1/category-banner", :name => ""
    #   expect_status(200)
    #   expect_json(ok: true)
    #   expect(JSON.parse(response.body).keys).to contain_exactly('ok', 'data')
    #   expect(JSON.parse(response.body)['data'].keys).to contain_exactly('name', 'slug', 'bannerImageUrl')
    #   expect_json('data.name', 'Math')
    #   expect(JSON.parse(response.body)['data']['slug']).to end_with('-math')
    #   expect_json('data.bannerImageUrl', '/assets/original/missing.png')
    # end
  end
end
