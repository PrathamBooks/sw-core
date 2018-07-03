require 'spec_helper'

RSpec.describe "Api::V1::Illustrations::Requests", :type => :request do

  before(:each) do
    @user= FactoryGirl.create(:user, :first_name => "Test", :last_name => "user")
    @person = FactoryGirl.create(:person_with_account, :user => @user)
    @illus_style = FactoryGirl.create(:style, :name => "Style1")
    @illus_cat = FactoryGirl.create(:illustration_category)
    @illustration = FactoryGirl.create(:illustration, :illustrators => [@person], :name => "Illustration1", :categories => [@illus_cat], :tag_list => "Tag_1", :styles => [@illus_style], :reads => 5)
    @illustration_1 = FactoryGirl.create(:illustration, :illustrators => [@person], :name => "Illustration2", :categories => [@illus_cat], :styles => [@illus_style])
    Illustration.reindex
    @story = create_story({illustration: @illustration, story_title: "Test story"})
    Story.reindex
  end
  let(:json) { JSON.parse(response.body) }

  #SHOW
  context "GET Illustration Details" do
  #Activate after code change
  #   it "should show the Illustration filters" do
  #     org1 = FactoryGirl.create(:org_publisher, id: 1, :organization_name => "Org_1")
  #     org2 = FactoryGirl.create(:org_publisher, id: 2, :organization_name => "Org_2")
  #     pub1= FactoryGirl.create(:publisher_org, organization_id: org1.id, :first_name => "publisher")
  #     person_2 = FactoryGirl.create(:person_with_account, :user => pub1)
  #     illustration_2 = FactoryGirl.create(:illustration, :illustrators => [person_2], :name => "Illustration3", :organization_id => org1.id, :styles => [@illus_style])
  #     Illustration.reindex
  #     Organization.reindex
  #     get '/api/v1/illustrations/filters'
  #     expect_json(ok: true)
  #     expect(JSON.parse(response.body).keys).to contain_exactly("ok", "data", "sortOptions")
  #     expect(JSON.parse(response.body)['data'].keys).to contain_exactly("style", "illustrator", "category", "publisher")
  #     expect(JSON.parse(response.body)['data']['style'].keys).to contain_exactly("name", "queryKey", "queryValues")
  #     expect(JSON.parse(response.body)['data']['style']['queryValues'][0].keys).to contain_exactly("name", "queryValue", "id")
  #     expect(JSON.parse(response.body)['data']['illustrator'].keys).to contain_exactly("name", "queryKey", "queryValues")
  #     expect(JSON.parse(response.body)['data']['illustrator']['queryValues'][0].keys).to contain_exactly("name", "queryValue")
  #     expect(JSON.parse(response.body)['data']['category'].keys).to contain_exactly("name", "queryKey", "queryValues")
  #     expect(JSON.parse(response.body)['data']['category']['queryValues'][0].keys).to contain_exactly("name", "queryValue", "id")
  #     expect(JSON.parse(response.body)['data']['publisher'].keys).to contain_exactly("name", "queryKey", "queryValues")
  #     expect(JSON.parse(response.body)['data']['publisher']['queryValues'][0].keys).to contain_exactly("name", "queryValue")
  #     expect(JSON.parse(response.body)['sortOptions'][0].keys).to contain_exactly("name", "queryValue")
  #     expect_json('data.style.name', 'Style')
  #     expect_json('data.style.queryKey', 'style')
  #     expect_json('data.style.queryValues.0.name', 'Style1')
  #     expect_json('data.style.queryValues.0.queryValue', 'Style1')
  #     expect_json('data.illustrator.name', 'Illustrator')
  #     expect_json('data.illustrator.queryKey', 'illustrator')
  #     expect(JSON.parse(response.body)['data']['illustrator']['queryValues'][0]['name']).to start_with("User first name ")
  #     #expect(JSON.parse(response.body)['data']['illustrator']['queryValues'][0]['queryValue']).to end_with('-test-user')
  #     #expect(JSON.parse(response.body)['data']['illustrator']['queryValues'][0]['queryValue']).to end_with('-publisher')
  #     expect_json('data.category.name', 'Category')
  #     expect_json('data.category.queryKey', 'category')
  #     expect_json('data.category.queryValues.0.name', 'Category1')
  #     expect_json('data.category.queryValues.0.queryValue', 'Category1')
  #     expect_json('data.publisher.name', 'Publisher')
  #     expect_json('data.publisher.queryKey', 'publisher')
  #     expect_json('data.publisher.queryValues.0.name', 'Org_1')
  #     expect_json('data.publisher.queryValues.0.queryValue', 'Org_1')
  #     expect_json('sortOptions.0.name', 'Most Liked')
  #     expect_json('sortOptions.0.queryValue', 'likes')
  #     expect_json('sortOptions.1.name', 'Most Viewed')
  #     expect_json('sortOptions.1.queryValue', 'views')
  #     expect_json('sortOptions.2.name', 'New Arrivals')
  #     expect_json('sortOptions.2.queryValue', 'published_at')
  #     expect(response).to be_success
  #     expect_status(200)
  #   end
    it "should show the Illustration details" do
      get "/api/v1/illustrations/#{@illustration.id}"
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('title', 'id', 'slug', 'categories', 'styles', 'license_type', 'attribution_text', 'liked', 'likesCount', 'readsCount', 'tags', 'imageUrls', 'illustrators', 'similarillustrations', 'downloadLinks', 'isFlagged', 'publisher', 'usedIn', 'downloadLimitReached', 'illustrationAccess')
      expect(JSON.parse(response.body)['data']['imageUrls'][0].keys).to contain_exactly('aspectRatio', 'cropCoords', 'sizes')
      expect(JSON.parse(response.body)['data']['imageUrls'][0]['sizes'][0].keys).to contain_exactly('height', 'width', 'url')
      expect(JSON.parse(response.body)['data']['illustrators'][0].keys).to contain_exactly('slug', 'name')
      expect(JSON.parse(response.body)['data']['similarillustrations'][0].keys).to contain_exactly('title', 'count', 'id', 'imageUrls', 'slug', 'illustrators')
      expect(JSON.parse(response.body)['data']['similarillustrations'][0]['illustrators'][0].keys).to contain_exactly('name', 'slug')
      #expect(JSON.parse(response.body)['data']['downloadLinks'][0].keys).to contain_exactly('type', 'href')
      expect(JSON.parse(response.body)['data']['similarillustrations'][0]['imageUrls'].keys).to contain_exactly('aspectRatio', 'cropCoords', 'sizes')
      expect(JSON.parse(response.body)['data']['similarillustrations'][0]['imageUrls']['cropCoords'].keys).to contain_exactly('x', 'y')
      expect(JSON.parse(response.body)['data']['similarillustrations'][0]['imageUrls']['sizes'][0].keys).to contain_exactly('height', 'width', 'url')
      expect(JSON.parse(response.body)['data']['usedIn'].keys).to contain_exactly('totalStories', 'stories')
      expect(JSON.parse(response.body)['data']['usedIn']['stories'][0].keys).to contain_exactly('title', 'slug')
      expect_json('data.title', 'Illustration1')
      expect(JSON.parse(response.body)['data']['slug']).to end_with('-illustration1')
      expect_json('data.categories', ['Category1'])
      expect_json('data.styles', ['Style1'])
      expect_json('data.license_type', 'CC BY 4.0')
      expect_json('data.attribution_text', 'This illustration is attributed to no one in particular.')
      expect_json('data.liked', false)
      expect_json('data.likesCount', 0)
      expect_json('data.readsCount', 6)
      expect_json('data.isFlagged', false)
      expect(JSON.parse(response.body)["data"]["tags"][0].keys).to contain_exactly("name", "query")
      expect_json('data.tags.0.name', 'Tag_1')
      expect_json('data.tags.0.query', 'Tag_1')
      expect_json('data.imageUrls.0.aspectRatio', 1.3333333333333333)
      expect_json('data.imageUrls.0.cropCoords.x', 0.0)
      expect_json('data.imageUrls.0.cropCoords.y', 0.0)
      expect_json('data.imageUrls.0.sizes.0.height', 100.0)
      expect_json('data.imageUrls.0.sizes.0.width', 100.0)
      expect(JSON.parse(response.body)['data']['imageUrls'][0]['sizes'][0]['url']).to start_with('/spec/test_files/illustrations/')
      expect(JSON.parse(response.body)['data']['illustrators'][0]['slug']).to end_with('-test-user')
      expect_json('data.illustrators.0.name', 'Test user')
      expect_json('data.similarillustrations.0.title', 'Illustration2')
      expect_json('data.similarillustrations.0.count', 1)
      expect_json('data.similarillustrations.0.imageUrls.aspectRatio', 1.3333333333333333)
      expect_json('data.similarillustrations.0.imageUrls.cropCoords.x', 0)
      expect_json('data.similarillustrations.0.imageUrls.cropCoords.y', 0)
      expect_json('data.similarillustrations.0.imageUrls.sizes.0.height', 100.0)
      expect_json('data.similarillustrations.0.imageUrls.sizes.0.width', 100.0)
      expect(JSON.parse(response.body)['data']['similarillustrations'][0]['imageUrls']['sizes'][0]['url']).to start_with('/spec/test_files/illustrations/')
      expect(JSON.parse(response.body)['data']['similarillustrations'][0]['slug']).to end_with('-illustration2')
      expect_json('data.similarillustrations.0.illustrators.0.name', 'Test user')
      expect(JSON.parse(response.body)['data']['similarillustrations'][0]['illustrators'][0]['slug']).to end_with('-test-user')
      # Commented this for the Gating enhancement feature
      # expect_json('data.downloadLinks.0.type', 'High Resolution')
      # expect_json('data.downloadLinks.1.type', 'Low Resolution')
      # expect(JSON.parse(response.body)['data']['downloadLinks'][0]['href']).to end_with('-illustration1?style=original')
      # expect(JSON.parse(response.body)['data']['downloadLinks'][1]['href']).to end_with('-illustration1?style=large')
      expect_json('data.usedIn.totalStories', 1)
      expect_json('data.usedIn.stories.0.title', 'Test story')
      expect(JSON.parse(response.body)['data']['usedIn']['stories'][0]['slug']).to end_with('-english-title1')
      expect(response).to be_success
      expect_status(200)
    end
  end
end
