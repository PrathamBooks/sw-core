require 'spec_helper'
require 'rails_helper'

RSpec.describe "Api::V1::Home::Requests", :type => :request do

  before(:each) do
    @user= FactoryGirl.create(:user)
    @list_category = FactoryGirl.create(:list_category)
  end

  let(:json) {JSON.parse(response.body)}

  context "GET home page details" do
    let(:front_cover_page_template) {FactoryGirl.create(:front_cover_page_template,default: true,orientation: 'landscape')}
    it "should show home page banner details and statistics" do
      banner1 = FactoryGirl.create(:banner)
      @original_story = FactoryGirl.create(:story, status: Story.statuses[:published], editor_recommended: true)
      @front_cover_page = FactoryGirl.create(:front_cover_page, story: @original_story, page_template: front_cover_page_template)
      generate_illustration_crop(@front_cover_page)
      Story.reindex
      Illustration.reindex
      get "/api/v1/home", format: :json
      x = JSON.parse(response.body)
      expect_json_keys([:ok, :data])
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("bannerImages", "editorsPick", "newArrivals", "mostRead", "blogPosts", "lists", "statistics")
      expect_json('data', blogPosts:[])
      expect_json('data', lists:[])
      expect(JSON.parse(response.body)['data']['bannerImages'][0].keys).to contain_exactly("id", "position", "pointToLink", "imageUrls")
      expect(JSON.parse(response.body)['data']['bannerImages'][0]['imageUrls'].keys).to contain_exactly("aspectRatio", "sizes")
      expect(JSON.parse(response.body)['data']['bannerImages'][0]['imageUrls']['sizes'][0].keys).to contain_exactly("width", "url")
      expect_json('data.bannerImages.0', position: 1)
      expect_json('data.bannerImages.0', pointToLink: 'www.google.com')
      expect_json('data.bannerImages.0.imageUrls', aspectRatio: 3.4026666666666667)
      expect_json('data.bannerImages.0.imageUrls.sizes.0', width: '692')
      expect(JSON.parse(response.body)['data']['bannerImages'][0]['imageUrls']['sizes'][0]['url']).to start_with('/spec/test_files/banners/')

      expect(JSON.parse(response.body)['data']['statistics'].keys).to contain_exactly("storiesCount","readsCount", "languagesCount")
      expect_json('data.statistics', storiesCount: 1)
      expect_json('data.statistics', readsCount: 0)
      expect_json('data.statistics', languagesCount: 1)
    end

    it "should show home page editorsPick details" do
      create_story
      @original_story = FactoryGirl.create(:story, status: Story.statuses[:published], editor_recommended: true)
      @front_cover_page = FactoryGirl.create(:front_cover_page, story: @original_story, page_template: front_cover_page_template)
      generate_illustration_crop(@front_cover_page)
      Story.reindex
      Illustration.reindex
      get "/api/v1/home", format: :json
      x = JSON.parse(response.body)
      expect_json_keys([:ok, :data])
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data']['editorsPick'].keys).to contain_exactly("meta", "results")
      expect(JSON.parse(response.body)['data']['editorsPick']['meta'].keys).to contain_exactly("hits", "perPage", "page", "totalPages")
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0].keys).to contain_exactly("id", "title", "language", "level", "slug", "recommended",  "editorsPick", "coverImage", "authors", "illustrators", "likesCount", "publisher", "readsCount", "description", "contest", "availableForOfflineMode", "storyDownloaded")
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0]['coverImage'].keys).to contain_exactly("aspectRatio", "cropCoords", "sizes")
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0]['coverImage']['sizes'][0].keys).to contain_exactly("height", "width", "url")
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0]['authors'][0].keys).to contain_exactly("slug","name")
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0]['illustrators'][0].keys).to contain_exactly("name", "slug")
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0]['publisher'].keys).to contain_exactly("name", "slug", "logo")
      expect_json('data.editorsPick.meta', hits: 2)
      expect_json('data.editorsPick.meta', perPage: 24)
      expect_json('data.editorsPick.meta', page: 1)
      expect_json('data.editorsPick.meta', totalPages: 1)
      expect_json('data.editorsPick.results.0', title: 'Full Story')
      expect_json('data.editorsPick.results.0', language: 'English')
      expect_json('data.editorsPick.results.0', level: '1')
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0]['slug']).to end_with('-full-story')
      expect_json('data.editorsPick.results.0', recommended: true)
      expect_json('data.editorsPick.results.0', editorsPick: true)
      expect_json('data.editorsPick.results.0.coverImage', aspectRatio: 1.0)
      expect(JSON.parse(response.body)["data"]["editorsPick"]["results"][0]["coverImage"]["cropCoords"].keys).to contain_exactly("x", "y")
      expect_json('data.editorsPick.results.0.coverImage.cropCoords.x', 0.0)
      expect_json('data.editorsPick.results.0.coverImage.cropCoords.y', 0.0)
      expect_json('data.editorsPick.results.0.coverImage.sizes.0', height: 100.0)
      expect_json('data.editorsPick.results.0.coverImage.sizes.0', width: 100.0)
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0]['coverImage']['sizes'][0]['url']).to start_with('/spec/test_files/illustration_crops/')
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0]['authors'][0]['slug']).to end_with('-test-user')
      expect_json('data.editorsPick.results.0.authors.0', name: 'Test user')
      expect_json('data.editorsPick.results.0.illustrators.0',slug: '')
      expect_json('data.editorsPick.results.0.illustrators.0',name: 'User first name 1 User last name 1')
      expect_json('data.editorsPick.results.0', readsCount: 0)
      expect_json('data.editorsPick.results.0', likesCount: 0)
      expect_json('data.editorsPick.results.0', description: 'Synopsis 1')
      expect_json('data.editorsPick.results.0.publisher', name: 'StoryWeaver Community')
      expect_json('data.editorsPick.results.0.publisher', slug: nil)
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0]['publisher']['logo']).to start_with('/assets/publisher_logos/')
      expect_json('data.editorsPick.results.0', contest: nil)
      expect_json('data.editorsPick.results.0.availableForOfflineMode', false)
      expect_json('data.editorsPick.results.0.storyDownloaded', false)
    end

    it "should show home page newArrivals details" do
      create_story
      user_2=FactoryGirl.create(:user, :first_name=> "Test", :last_name => "user")
      @person = FactoryGirl.create(:person_with_account, :user => user_2)
      @illustration = FactoryGirl.create(:illustration, :illustrators => [@person], :name => "Illustration1", :reads => 5)
      Illustration.reindex
      @original_story = FactoryGirl.create(:story, :authors =>[user_2], status: Story.statuses[:published], editor_recommended: true)
      @front_cover_page = FactoryGirl.create(:front_cover_page, story: @original_story, page_template: front_cover_page_template)
      generate_illustration_crop(@front_cover_page, @illustration)
      org1 = FactoryGirl.create(:org_publisher, id: 1)
      @pub1= FactoryGirl.create(:publisher_org, organization_id: org1.id)
      kannada = FactoryGirl.create( :kannada)

      story1 = FactoryGirl.create(:level_1_story, language: kannada, title: "story1", :status => Story.statuses[:published], :authors => [@pub1], :organization_id => org1.id )
      Organization.reindex
      Story.reindex
      get "/api/v1/home", format: :json
      x = JSON.parse(response.body)
      expect_json_keys([:ok, :data])
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data']['newArrivals'].keys).to contain_exactly("meta", "results")
      expect(JSON.parse(response.body)['data']['newArrivals']['meta'].keys).to contain_exactly("hits", "perPage", "page", "totalPages")
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0].keys).to contain_exactly("id", "title", "language", "level", "slug", "recommended", "editorsPick", "coverImage", "authors", "illustrators", "likesCount", "publisher", "readsCount", "description", "contest", "availableForOfflineMode", "storyDownloaded")
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['coverImage'].keys).to contain_exactly('aspectRatio', 'cropCoords', 'sizes')
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['coverImage']['sizes'][0].keys).to contain_exactly('height', 'width', 'url')
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['authors'][0].keys).to contain_exactly("slug", "name")
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['illustrators'][0].keys).to contain_exactly("name", "slug")
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['publisher'].keys).to contain_exactly("name", "slug", "logo")
      expect_json('data.newArrivals.meta', hits: 3)
      expect_json('data.newArrivals.meta', perPage: 24)
      expect_json('data.newArrivals.meta', page: 1)
      expect_json('data.newArrivals.meta', totalPages: 1)
      expect_json('data.newArrivals.results.0', title: 'Full Story')
      expect_json('data.newArrivals.results.0', language: 'English')
      expect_json('data.newArrivals.results.0', level: '1')
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['slug']).to end_with('-full-story')
      expect_json('data.newArrivals.results.0', recommended: true)
      expect_json('data.newArrivals.results.0', editorsPick: true)
      expect_json('data.newArrivals.results.0.coverImage', aspectRatio: 1.0)
      expect_json('data.newArrivals.results.0.coverImage.sizes.0', height: 100.0)
      expect_json('data.newArrivals.results.0.coverImage.sizes.0', width: 100.0)
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['coverImage']['sizes'][0]['url']).to start_with('/spec/test_files/illustration_crops/')
      expect(JSON.parse(response.body)["data"]["newArrivals"]["results"][0]["coverImage"]["cropCoords"].keys).to contain_exactly("x", "y")
      expect_json('data.newArrivals.results.0.coverImage.cropCoords.x', 0.0)
      expect_json('data.newArrivals.results.0.coverImage.cropCoords.y', 0.0)
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['authors'][0]['slug']).to end_with('-test-user')
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['authors'][0]['name']).to start_with('Test user')
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['illustrators'][0]['name']).to start_with('User first name')
      expect_json('data.newArrivals.results.0.illustrators.0.slug', "")
      expect_json('data.newArrivals.results.0', readsCount:0)
      expect_json('data.newArrivals.results.0', likesCount:0)
      expect_json('data.newArrivals.results.0', description:'Synopsis 1')
      expect_json('data.newArrivals.results.0.publisher', name:'StoryWeaver Community')
      expect_json('data.newArrivals.results.0.publisher', slug:nil)
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['publisher']['logo']).to start_with('/assets/publisher_logos/')
      expect_json('data.newArrivals.results.0', contest: nil)
      expect_json('data.newArrivals.results.0', availableForOfflineMode: false)
      expect_json('data.newArrivals.results.0.storyDownloaded', false)
    end

    it "should show home page mostRead details" do
      story = create_story
      story.reads = 500
      story.save
      user_3 = FactoryGirl.create(:user, :first_name => "Test", :last_name => "user")
      @person = FactoryGirl.create(:person_with_account, :user => user_3)
      @illustration = FactoryGirl.create(:illustration, :illustrators => [@person], :name => "Illustration1", :reads => 5)
      Illustration.reindex
      @original_story = FactoryGirl.create(:story, :authors =>[user_3], status: Story.statuses[:published], editor_recommended: true)
      @front_cover_page = FactoryGirl.create(:front_cover_page, story: @original_story, page_template: front_cover_page_template)
      generate_illustration_crop(@front_cover_page, @illustration)
      Story.reindex
      Illustration.reindex
      get "/api/v1/home", format: :json
      x = JSON.parse(response.body)
      expect_json_keys([:ok, :data])
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data']['mostRead'].keys).to contain_exactly("meta","results")
      expect(JSON.parse(response.body)['data']['mostRead']['meta'].keys).to contain_exactly("hits", "perPage", "page", "totalPages")
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0].keys).to contain_exactly("id", "title", "language", "level", "slug", "recommended", "editorsPick", "coverImage", "authors", "illustrators", "likesCount", "publisher", "readsCount", "description", "contest", "availableForOfflineMode", "storyDownloaded")
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['coverImage'].keys).to contain_exactly('aspectRatio', 'cropCoords', 'sizes')
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['coverImage']['sizes'][0].keys).to contain_exactly('height', 'width', 'url')
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['authors'][0].keys).to contain_exactly("slug", "name")
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['illustrators'][0].keys).to contain_exactly("name", "slug")
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['publisher'].keys).to contain_exactly("name", "slug", "logo")
      expect_json('data.mostRead.meta', hits: 2)
      expect_json('data.mostRead.meta', perPage: 24)
      expect_json('data.mostRead.meta', page: 1)
      expect_json('data.mostRead.meta', totalPages: 1)
      expect_json('data.mostRead.results.0', title: 'Full Story')
      expect_json('data.mostRead.results.0', language: 'English')
      expect_json('data.mostRead.results.0', level: '1')
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['slug']).to end_with('-full-story')
      expect_json('data.mostRead.results.0', recommended: true)
      expect_json('data.mostRead.results.0', editorsPick: true)
      expect_json('data.mostRead.results.0.coverImage', aspectRatio: 1.0)
      expect_json('data.mostRead.results.0.coverImage.sizes.0', height: 100.0)
      expect_json('data.mostRead.results.0.coverImage.sizes.0', width: 100.0)
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['coverImage']['sizes'][0]['url']).to start_with('/spec/test_files/illustration_crops/')
      expect(JSON.parse(response.body)["data"]["mostRead"]["results"][0]["coverImage"]["cropCoords"].keys).to contain_exactly("x", "y")
      expect_json('data.mostRead.results.0.coverImage.cropCoords.x', 0.0)
      expect_json('data.mostRead.results.0.coverImage.cropCoords.y', 0.0)
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['authors'][0]['slug']).to end_with('-test-user')
      expect_json('data.mostRead.results.0.authors.0.name', "Test user")
      expect_json('data.mostRead.results.0.illustrators.0.slug', "")
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['illustrators'][0]['name']).to start_with('User first name ')
      expect_json('data.mostRead.results.0', readsCount:500)
      expect_json('data.mostRead.results.0', likesCount:0)
      expect_json('data.mostRead.results.0', description:'Synopsis 1')
      expect_json('data.mostRead.results.0.publisher', name:'StoryWeaver Community')
      expect_json('data.mostRead.results.0.publisher', slug:nil)
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['publisher']['logo']).to start_with('/assets/publisher_logos/')
      expect_json('data.mostRead.results.0', contest:nil)
      expect_json('data.mostRead.results.0', availableForOfflineMode: false)
      expect_json('data.mostRead.results.0.storyDownloaded', false)
    end
  end
  context "GET footer images" do
    it "should show footer images" do
      footer_image = FactoryGirl.create(:footer_image)
      Illustration.reindex
      get "/api/v1/footer_images", format: :json
      x = JSON.parse(response.body)
      expect(JSON.parse(response.body).keys).to contain_exactly("ok", "data")
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data']['images'][0].keys).to contain_exactly("title", "id", "aspectRatio", "cropCoords", "sizes", "slug")
      expect(response.body).to match("/spec/test_files/illustrations/")
      crop_coords = x["data"]["images"].collect{|z| z["cropCoords"]}
      crop_coords.should =~ [{"x"=>0.0, "y"=>0.0}]
      expect(JSON.parse(response.body)['data']['images'][0]['sizes'][0].keys).to contain_exactly("height", "width", "url")
      expect_status(200)
    end
  end
  context "GET all categories" do
    it "should show all categories" do
      @story_category = FactoryGirl.create_list(:story_category, 5)
      get "/api/v1/get_categories", format: :json
      expect((@story_category).count).to eq(5)
      expect_status(200)
    end
  end
  context "Get recommendations" do
    it "should show recommended stories" do
      story_list = FactoryGirl.create_list(:story, 11, status: Story.statuses[:published])
      Story.reindex
      FactoryGirl.create_list(:story_read, 10, story_id: story_list[9].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 9, story_id: story_list[2].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 11, story_id: story_list[3].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 12, story_id: story_list[4].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 18, story_id: story_list[5].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 1, story_id: story_list[6].id, user_id: User.first.id)
      get "/api/v1/home/recommendations", format: :json
      expect_json(ok: true)
      expect(JSON.parse(response.body).keys).to contain_exactly("ok", "data")
      expect_json_keys('data', [:recommendedStories])
      expect_json('data.recommendedStories.0.title', "Title6")
      expect_json('data.recommendedStories.4.title', "Title3")
      expect_status(200)
    end
  end

  context "GET home categories" do
    #in categories.json.jbuilder file its taking as I18n.t("categories."+cat.name), code change required.
    it "should show categories in home page"
    # do
    #   @story_category = FactoryGirl.create_list(:story_category, 5, )
    #   sc = StoryCategory.all
    #   sc.each do|s|
    #     ss = s.translation
    #     ss.translated_name = ss.name
    #     ss.save!
    #   end[0]
    #   get "api/v1//home/categories", format: :json
    #   expect((@story_category).count).to eq(5)
    #   expect_status(200)
    #   expect_json(ok: true)
    #   expect(JSON.parse(response.body).keys).to contain_exactly("ok", "data")
    #   expect(JSON.parse(response.body)['data'][0].keys).to contain_exactly('name', 'queryValue', 'slug', 'imageUrls')
    #   expect(JSON.parse(response.body)['data'][0]['name']).to start_with('Category')
    #   expect(JSON.parse(response.body)['data'][0]['queryValue']).to start_with('Category')
    #   expect(response.body).to match('-category-')
    #   expect(JSON.parse(response.body)['data'][0]['imageUrls'].keys).to contain_exactly('aspectRatio', 'sizes')
    #   expect_json('data.0.imageUrls.aspectRatio', 2.3384615384615386)
    #   expect(JSON.parse(response.body)['data'][0]['imageUrls']['sizes'][0].keys).to contain_exactly('width', 'url')
    #   expect_json('data.0.imageUrls.sizes.0.width', "240")
    #   expect(JSON.parse(response.body)['data'][0]['imageUrls']['sizes'][0]['url']).to start_with('/assets/size_1/')
    # end
  end
end
