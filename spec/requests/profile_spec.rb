require 'spec_helper'

RSpec.describe "Api::V1::Profile::Requests", :type => :request do

  before(:each) do
    @user= FactoryGirl.create(:user)
    @list_category = FactoryGirl.create(:list_category)
  end
  let(:json) { JSON.parse(response.body) }

context "GET user details" do
    it "should show user details" do
      english = FactoryGirl.create( :english)
      kannada = FactoryGirl.create( :kannada)
      person = FactoryGirl.create(:person_with_account, :user => @user)
      story = FactoryGirl.create(:story,language: english, title: "English Story", :status => Story.statuses[:published], :authors => [@user])
      illustration = FactoryGirl.create(:illustration, :illustrators => [person])
      translated_story = story.new_derivation(FactoryGirl.attributes_for(:story, title: "Translated_story", language_id: kannada.id).slice!(:id), story.authors.first, story.authors.first, "translated")
      translated_story.save!
      relevelled_story = story.new_derivation(FactoryGirl.attributes_for(:story, title: "Relevelled_story", reading_level: "2", language_id: story.language.id).slice!(:id), story.authors.first, story.authors.first, "relevelled")
      relevelled_story.save!
      list = FactoryGirl.create(:list, user: @user, :title=> "New List" )
      Story.reindex
      List.reindex
      User.reindex
      Illustration.reindex
      get "/api/v1/users/#{@user.id}"
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('slug', 'name', 'description', 'email', 'website', 
        'profileImage', 'id', 'books', 'translations', 'lists', 'illustrations', 'mediaMentions', 'organization', 'releveled_stories')
      expect_json(ok: true)
      expect_status(200)
    end
  end

  context "GET organization details" do
    it "should list organization details" do
      org1 = FactoryGirl.create(:organization, id: 1)
      story_create = FactoryGirl.create(:story, status: Story.statuses[:published], organization_id: 1)
      get "/api/v1/organisations/#{org1.id}"
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('type', 'name', 'id', 'description', 'email', 'website', 'profileImage', 'slug', 'reading_lists', 'mediaMentions', 'socialMediaLinks')
      expect_json('data.type', 'ORGANISATION')
      expect_json('data.name', 'organization_name 1')
      expect_json('data.profileImage', '/assets/original/missing.png')
      expect(response).to be_success
      expect_status(200)
    end
    it "should show 404 error while passing publisher" do
      org1 = FactoryGirl.create(:organization, id: 1)
      story_create = FactoryGirl.create(:story, status: Story.statuses[:published], organization_id: 1)
      get "/api/v1/publishers/#{org1.id}"
      expect_json(ok: false)
      expect_json('data.errorMessage', "The URI requested is invalid. Resource requested doesn't exist")
      expect_status(404)
    end
  end

  context "GET publishers details" do
    it "should list publishers details" do
      pub1 = FactoryGirl.create(:org_publisher, id: 1)
      list_of_lists = FactoryGirl.create_list(:list, 4, user: @user, organization_id: 1)
      story_create = FactoryGirl.create_list(:story, 5, status: Story.statuses[:published], organization_id: 1)
      Organization.reindex
      List.reindex
      Story.reindex
      get "/api/v1/publishers/#{pub1.id}"
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('type', 'name', 'id', 'description', 'email', 'website', 
        'profileImage', 'slug', 'reading_lists', 'mediaMentions', 'socialMediaLinks', 'newArrivals', 'editorsPick')
      ['reading_lists', 'mediaMentions', 'newArrivals', 'editorsPick'].each do |data|
        expect(JSON.parse(response.body)['data']["#{data}"].keys).to contain_exactly('meta', 'results')
      end
      ['reading_lists', 'mediaMentions', 'newArrivals', 'editorsPick'].each do |data|
       expect(JSON.parse(response.body)['data']["#{data}"]['meta'].keys).to contain_exactly('hits', 'perPage', 'page', 'totalPages')
      end
      expect(JSON.parse(response.body)['data']['socialMediaLinks'].keys).to contain_exactly('facebookUrl', 'rssUrl', 'twitterUrl', 'youtubeUrl')
      expect(response).to be_success
      expect_status(200)
    end
    it "should show 404 error while passing organisation" do
      org1 = FactoryGirl.create(:org_publisher, id: 1)
      story_create = FactoryGirl.create(:story, status: Story.statuses[:published], organization_id: 1)
      get "/api/v1/organisations/#{org1.id}"
      expect_json(ok: false)
      expect_json('data.errorMessage', "The URI requested is invalid. Resource requested doesn't exist")
      expect_status(404)
    end
  end

  context "PUT popup-seen" do
    it "should set_popup_seen - without login" do
      put "/api/v1/user/popup-seen"
      expect_status(400)
      expect_json(ok: false)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('errorCode', 'errorMessage')
      expect_json('data.errorCode', 400)
      expect_json('data.errorMessage', 'Unable to find user')
    end
  end

  context "PUT set_offline_book_popup_seen" do
    it "should set-offline-book-popup-seen- without login" do
      put "/api/v1/user/offline-book-popup-seen"
      expect_status(401)
    end
  end
end
