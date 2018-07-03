require 'rails_helper'
require 'spec_helper'

describe Api::V1::IllustrationsController, :type => :controller do

  render_views
  before(:each) do
    @user= FactoryGirl.create(:user, :first_name => "Test", :last_name => "user")
    @person = FactoryGirl.create(:person_with_account, :user => @user)
    @illus_style = FactoryGirl.create(:style, :name => "Style1")
    @illus_cat = FactoryGirl.create(:illustration_category)
    @illustration = FactoryGirl.create(:illustration, :illustrators => [@person], :name => "Illustration1", :categories => [@illus_cat], :tag_list => "Tag_1", :styles => [@illus_style], :reads => 5)
    @illustration_1 = FactoryGirl.create(:illustration, :illustrators => [@person], :name => "Illustration2", :categories => [@illus_cat], :styles => [@illus_style])
    Illustration.reindex
  end
  let(:json) { JSON.parse(response.body) }

#SHOW
  context "SHOW/GET Illustrations Details" do
    it "should show the illustration details" do
      sign_in @user
      organisation = FactoryGirl.create(:org_publisher, :id => 2, :organization_name => "Test Org", :website => "www.testorg.com", :logo => Rack::Test::UploadedFile.new('spec/photos/logo.png', 'image/png'))
      publisher= FactoryGirl.create(:publisher_org, organization_id: organisation.id)
      5.times {@illustration.liked_by FactoryGirl.create(:user)}
      @illustration.liked_by @user
      @illustration.organization_id = organisation.id
      @illustration.publisher_id = publisher.id
      @illustration.save!
      Illustration.reindex
      story = create_story({illustration: @illustration})
      Story.reindex
      get :show, :id => @illustration.id, format: :json
      expect_status(200)
      expect(ok: true)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('title', 'id', 'slug', 'categories', 'styles', 'license_type', 'attribution_text', 'liked', 'likesCount', 'readsCount', 'isFlagged', 'tags', 'imageUrls', 'illustrators', 'similarillustrations', 'downloadLinks', 'publisher', 'usedIn', 'downloadLimitReached', 'illustrationAccess')
      expect(JSON.parse(response.body)['data']['imageUrls'][0].keys).to contain_exactly('aspectRatio', 'cropCoords', 'sizes')
      expect(JSON.parse(response.body)['data']['imageUrls'][0]['sizes'][0].keys).to contain_exactly('height', 'width', 'url')
      expect(JSON.parse(response.body)['data']['illustrators'][0].keys).to contain_exactly('slug', 'name')
      expect(JSON.parse(response.body)['data']['downloadLinks'][0].keys).to contain_exactly('type', 'href')
      expect(JSON.parse(response.body)['data']['similarillustrations'][0].keys).to contain_exactly('title', 'count', 'id', 'imageUrls', 'slug', 'illustrators')
      expect(JSON.parse(response.body)['data']['similarillustrations'][0]['imageUrls'].keys).to contain_exactly('aspectRatio', 'cropCoords', 'sizes')
      expect(JSON.parse(response.body)['data']['similarillustrations'][0]['imageUrls']['cropCoords'].keys).to contain_exactly('x', 'y')
      expect(JSON.parse(response.body)['data']['similarillustrations'][0]['imageUrls']['sizes'][0].keys).to contain_exactly('height', 'width', 'url')
      expect(JSON.parse(response.body)['data']['similarillustrations'][0]['illustrators'][0].keys).to contain_exactly('name', 'slug')
      expect(JSON.parse(response.body)['data']['usedIn'].keys).to contain_exactly('totalStories', 'stories')
      expect(JSON.parse(response.body)['data']['usedIn']['stories'][0].keys).to contain_exactly('title', 'slug')
      expect_json('data.title', 'Illustration1')
      expect(JSON.parse(response.body)['data']['slug']).to end_with('-illustration1')
      expect_json('data.categories', ['Category1'])
      expect_json('data.styles', ['Style1'])
      expect_json('data.license_type', 'CC BY 4.0')
      expect_json('data.attribution_text', 'This illustration is attributed to no one in particular.')
      expect_json('data.liked', true)
      expect_json('data.likesCount', 6)
      expect_json('data.readsCount', 6)
      expect_json('data.isFlagged', false)
      expect(JSON.parse(response.body)["data"]["tags"][0].keys).to contain_exactly("name", "query")
      expect_json('data.tags.0.name', 'Tag_1')
      expect_json('data.tags.0.query', 'Tag_1')
      expect(JSON.parse(response.body)["data"]["publisher"].keys).to contain_exactly("slug", "name", "website", "logo")
      expect(JSON.parse(response.body)['data']['publisher']['slug']).to end_with('-test-org')
      expect_json('data.publisher.name', 'Test Org')
      expect_json('data.publisher.website', 'www.testorg.com')
      expect(JSON.parse(response.body)['data']['publisher']['logo']).to start_with('/spec/test_files/organizations/')
      expect_json('data.imageUrls.0.aspectRatio', 1.3333333333333333)
      expect_json('data.imageUrls.0.cropCoords.x', 0.0)
      expect_json('data.imageUrls.0.cropCoords.y', 0.0)
      expect_json('data.imageUrls.0.sizes.0.height', 100.0)
      expect_json('data.imageUrls.0.sizes.0.width', 100.0)
      expect(JSON.parse(response.body)['data']['imageUrls'][0]['sizes'][0]['url']).to start_with('/spec/test_files/illustrations/')
      expect(JSON.parse(response.body)['data']['illustrators'][0]['slug']).to end_with('test-user')
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
      expect_json('data.downloadLinks.0.type', 'JPEG')
      expect_json('data.downloadLinks.1.type', 'HiRes JPEG')
      expect(JSON.parse(response.body)['data']['downloadLinks'][0]['href']).to end_with('-illustration1?style=large')
      expect(JSON.parse(response.body)['data']['downloadLinks'][1]['href']).to end_with('-illustration1?style=original')
      expect_json('data.usedIn.totalStories', 1)
      expect_json('data.usedIn.stories.0.title', 'Full Story')
      expect(JSON.parse(response.body)['data']['usedIn']['stories'][0]['slug']).to end_with('-english-title1')

      expect(response).to be_success
    end
  end
#Uncomment after code change
#FILTERS
  # context "SHOW/GET Illustration filters" do
  #   it "should show the illustration filters" do
  #     org1 = FactoryGirl.create(:org_publisher, id: 1, :organization_name => "Org_1")
  #     org2 = FactoryGirl.create(:org_publisher, id: 2, :organization_name => "Org_2")
  #     pub1= FactoryGirl.create(:publisher_org, organization_id: org1.id, :first_name => "publisher")
  #     person_2 = FactoryGirl.create(:person_with_account, :user => pub1)
  #     illustration_2 = FactoryGirl.create(:illustration, :illustrators => [person_2], :name => "Illustration3", :organization_id => org1.id, :styles => [@illus_style])
  #     Illustration.reindex
  #     Organization.reindex
  #     User.reindex
  #     get :filters, format: :json
  #     expect(ok: true)
  #     expect(JSON.parse(response.body)['data'].keys).to contain_exactly('style', 'illustrator', 'category', 'publisher')
  #     expect(JSON.parse(response.body)['data']['style'].keys).to contain_exactly('name', 'queryKey', 'queryValues')
  #     expect(JSON.parse(response.body)['data']['style']['queryValues'][0].keys).to contain_exactly('name', 'queryValue', 'id')
  #     expect(JSON.parse(response.body)['data']['illustrator'].keys).to contain_exactly('name', 'queryKey', 'queryValues')
  #     expect(JSON.parse(response.body)['data']['illustrator']['queryValues'][0].keys).to contain_exactly('name', 'queryValue')
  #     expect(JSON.parse(response.body)['data']['category'].keys).to contain_exactly('name', 'queryKey', 'queryValues')
  #     expect(JSON.parse(response.body)['data']['category']['queryValues'][0].keys).to contain_exactly('name', 'queryValue', 'id')
  #     expect(JSON.parse(response.body)['data']['publisher'].keys).to contain_exactly('name', 'queryKey', 'queryValues')
  #     expect(JSON.parse(response.body)['data']['publisher']['queryValues'][0].keys).to contain_exactly('name', 'queryValue')
  #     expect(JSON.parse(response.body)['sortOptions'][0].keys).to contain_exactly('name', 'queryValue')
  #     expect_json('data.style.name', 'Style')
  #     expect_json('data.style.queryKey', 'style')
  #     expect_json('data.style.queryValues.0.name', 'Style1')
  #     expect_json('data.style.queryValues.0.queryValue', 'Style1')
  #     expect_json('data.illustrator.name', 'Illustrator')
  #     expect_json('data.illustrator.queryKey', 'illustrator')
  #     expect(JSON.parse(response.body)['data']['illustrator']['queryValues'][0]['name']).to start_with('User first name ')
  #     #will uncomment after code stabilized
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
  # end
  context "POST/Like an illustration with current user and different user" do
    it "should be able to like a illustration" do
      sign_in @user
      get :show, :id => @illustration, format: :json
      expect(ok: true)
      expect_json('data.liked', false)
      post :illustration_like, :id=> @illustration, format: :json
      expect(ok: true)
      get :show, :id => @illustration, format: :json
      expect(ok: true)
      expect_json('data.liked', true)
      expect_json('data.likesCount', 1)
      sign_out @user

      #same user cannot like an illustration twice
      sign_in @user
      post :illustration_like, :id=> @illustration, format: :json
      expect(ok: true)
      get :show, :id => @illustration, format: :json
      expect(ok: true)
      expect_json('data.liked', true)
      expect_json('data.likesCount', 1)
      sign_out @user

      #Likes count has to increase if it is a different user
      user_2 = FactoryGirl.create(:user)
      sign_in user_2
      get :show, :id => @illustration, format: :json
      expect(ok: true)
      expect_json('data.liked', false)
      expect_json('data.likesCount', 1)
      post :illustration_like, :id=> @illustration, format: :json
      expect(ok: true)
      get :show, :id => @illustration, format: :json
      expect(ok: true)
      expect_json('data.liked', true)
      expect_json('data.likesCount', 2)
      sign_out user_2

      #Cannot like without login
      get :show, :id => @illustration, format: :json
      expect(ok: true)
      expect_json('data.liked', false)
      expect_json('data.likesCount', 2)
      post :illustration_like, :id=> @illustration, format: :json
      expect(ok: true)
      expect_json('error', 'You need to sign in or sign up before continuing.')
    end
  end
  context "DELETE/Unlike an illustration with current user and different user" do
    it "should be able to unlike a illustration" do
      sign_in @user
      @illustration.liked_by @user
      get :show, :id => @illustration, format: :json
      expect(ok: true)
      expect_json('data.liked', true)
      expect_json('data.likesCount', 1)
      expect(Illustration.find(@illustration.id).likes).to eq(1)
      post :illustration_unlike, :id=> @illustration, format: :json
      expect(ok: true)
      get :show, :id => @illustration, format: :json
      expect(ok: true)
      expect_json('data.liked', false)
      expect_json('data.likesCount', 0)
    end
    it "should be able to unlike a illustration with other user" do
      user_2 = FactoryGirl.create(:user)
      sign_in user_2
      @illustration.liked_by user_2
      sign_out user_2

      sign_in @user
      @illustration.liked_by @user
      get :show, :id => @illustration, format: :json
      expect(ok: true)
      expect_json('data.liked', true)
      expect_json('data.likesCount', 2)
      post :illustration_unlike, :id=> @illustration, format: :json
      expect(ok: true)
      get :show, :id => @illustration, format: :json
      expect(ok: true)
      expect_json('data.liked', false)
      expect_json('data.likesCount', 1)
      sign_out @user

      #Cannot dislike with out login
      get :show, :id => @illustration, format: :json
      expect(ok: true)
      expect_json('data.liked', false)
      expect_json('data.likesCount', 1)
      post :illustration_unlike, :id=> @illustration, format: :json
      expect(ok: true)
      expect_json('error', 'You need to sign in or sign up before continuing.')
    end
  end
  context "POST/Flag an illustration" do
    it "should be able to flag an illustration only once" do
      sign_in @user
      expect(Illustration.find(@illustration.id).flaggings_count).to eq(nil)
      post :flag_illustration, {:reasons => ["other"], :otherReason => "test",:id => @illustration.id}, format: :json
      expect_json(ok: true)
      expect(Illustration.find(@illustration.id).flaggings_count).to eq(1)
      post :flag_illustration, {:reasons => ["other"], :otherReason => "test",:id => @illustration.id}, format: :json
      expect_json(ok: false)
      expect_json('data.errorMessage', 'User had already flagged this Illustration.')
      expect_status(422)
      expect(Illustration.find(@illustration.id).flaggings_count).to eq(1)
    end
    it "should not be able to flag an illustration with empty reason" do
      sign_in @user
      expect(Illustration.find(@illustration.id).flaggings_count).to eq(nil)
      post :flag_illustration, {:reasons => ["other"],:id => @illustration.id}, format: :json
      expect_json(ok: false)
      expect_json('data.errorMessage', 'Reason cannot be empty')
      expect_status(400)
      expect(Illustration.find(@illustration.id).flaggings_count).to eq(nil)
    end
    it "should not be able to flag an illustration without login"
      # pending - api returning wrong json
      # do
      # get :show, :id => @illustration.id, format: :json
      # expect(ok: true)
      # expect_json('data.isFlagged', false)
      # post :flag_illustration, {:reasons => ["other"], :otherReason => "test",:id => @illustration.id}, format: :json
      # expect_json(ok: true)
      # expect_json('error', 'You need to sign in or sign up before continuing.')
      # end
  end
end
