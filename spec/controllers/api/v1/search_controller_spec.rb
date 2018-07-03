require 'rails_helper'
require 'spec_helper'

describe Api::V1::SearchController, :type => :controller do

  render_views
  before(:each) do
    @user= FactoryGirl.create(:user)
    @list_category = FactoryGirl.create(:list_category)
  end

  let(:json) { JSON.parse(response.body) }
  #books-for-translation for controller method
  context "GET translations" do
    it "should show zero translations" do
      sign_in @user
      stories = FactoryGirl.create_list(:story, 3)
      Story.reindex
      expect(Story.all.count).to eq(3)
      get :books_for_translation, format: :json
      expect_json(ok: true)
      expect_json('data', [])
    end

    it "should show translations with applied filters" do
      sign_in @user
      org1 = FactoryGirl.create(:org_publisher, id: 1)
      org2 = FactoryGirl.create(:org_publisher, id: 2)
      @pub1= FactoryGirl.create(:publisher_org, organization_id: org1.id)
      @pub2= FactoryGirl.create(:publisher_org, organization_id: org2.id)
      english = FactoryGirl.create( :english)
      kannada = FactoryGirl.create( :kannada)
      hindi = FactoryGirl.create( :hindi)

      cat_1 = FactoryGirl.create(:story_category)
      cat_2 = FactoryGirl.create(:story_category)
      story1 = FactoryGirl.create(:level_1_story,language: english, title: "story1", :categories => [cat_1], :status => Story.statuses[:published], :authors => [@pub1], :organization_id => 1 )
      story2 = FactoryGirl.create(:level_2_story,language: kannada, title: "story2", :categories => [cat_2], :status => Story.statuses[:published], :authors => [@pub1], :organization_id => 1 )
      story3 = FactoryGirl.create(:level_1_story,language: english, title: "story3", :categories => [cat_1], :status => Story.statuses[:published], :authors => [@pub2], :organization_id => 2 )
      story4 = FactoryGirl.create(:level_2_story,language: kannada, title: "story4", :categories => [cat_2], :status => Story.statuses[:published], :authors => [@pub2], :organization_id => 2 )
      story5 = FactoryGirl.create(:level_1_story,language: kannada, title: "story5", :categories => [cat_2], :status => Story.statuses[:published], :organization_id => 2 )
      story6 = FactoryGirl.create(:level_3_story,language: hindi, title: "story6", :status => Story.statuses[:published])
      Organization.reindex
      User.reindex
      Story.reindex
      expect(Story.all.count).to eq(6)
      #To check for publisher stories only
      get :books_for_translation, format: :json
      expect(response.body).should_not match("story6")
      #to validate specific publisher story is displaying or not
      arguments = {:publishers => [org2.organization_name]}
      get :books_for_translation, arguments, format: :json
      expect_json('data.0.title', 'story3')
      expect_json('data.1.title', 'story4')
      #to validate specific publisher story with reading level 1 is displaying or not
      arguments = {:publishers => [org1.organization_name], :reading_levels => [1]}
      get :books_for_translation, arguments, format: :json
      expect_json('data.0.title', 'story1')
      expect_json('data.0.level', '1')
      #validate stories are displaying on by giving reading levels
      arguments = {:reading_levels => [1]}
      get :books_for_translation, arguments, format: :json
      expect_json('data.0.level', '1')
      expect_json('data.*.level', '1')
      #validate stories by giving languages
      arguments = {:source_language => "Kannada"}
      get :books_for_translation, arguments, format: :json
      expect_json('data.0.language', 'Kannada')
      expect_json('data.*.language', 'Kannada')

      arguments = {:categories => [cat_1.name]}
      get :books_for_translation, arguments, format: :json
      expect_json('data.0.title', 'story1')
      expect_json('data.1.title', 'story3')

      arguments = {:publishers => [org1.organization_name], :categories => [cat_2.name]}
      get :books_for_translation, arguments, format: :json
      expect_json('data.0.title', 'story2')

      arguments = {:categories => [cat_2.name], :reading_levels => [1]}
      get :books_for_translation, arguments, format: :json
      expect_json('data.0.title', 'story5')

      expect_status(200)
      expect(response).to have_http_status(:success)
    end

    it "should show translations with from and to languages selected" do
      org1 = FactoryGirl.create(:org_publisher, id: 1)
      org2 = FactoryGirl.create(:org_publisher, id: 2)
      org3 = FactoryGirl.create(:org_publisher, id: 3)
      @pub1= FactoryGirl.create(:publisher_org, organization_id: org1.id)
      @pub2= FactoryGirl.create(:publisher_org, organization_id: org2.id)
      #new_user = FactoryGirl.create(:user)
      english = FactoryGirl.create( :english)
      hindi = FactoryGirl.create( :hindi)
      kannada = FactoryGirl.create( :kannada)
      telugu = FactoryGirl.create( :telugu)
      story1 = FactoryGirl.create(:story,language: english, title: "org_story1", :status => Story.statuses[:published], :organization_id => 1 )
      story2 = FactoryGirl.create(:story,language: hindi, title: "org_story2", :status => Story.statuses[:published], :organization_id => 2 )
      story3 = FactoryGirl.create(:story,language: english, title: "story1", :status => Story.statuses[:published])
      #story4 = FactoryGirl.create(:story,language: telugu, title: "org_story3", :status => Story.statuses[:published], :organization_id => 2 )
      translated_story1 = story1.new_derivation(FactoryGirl.attributes_for(:story, title: "Translated_story1", language_id: kannada.id).slice!(:id), story1.authors.first, @pub2, "translated")
      translated_story1.save!
      translated_story2 = story2.new_derivation(FactoryGirl.attributes_for(:story, title: "Translated_story2", language_id: english.id).slice!(:id), story2.authors.first, @pub1, "translated")
      translated_story2.save!
      #Need to activate below steps after finishing rate and review
      #translated_story3 = story1.new_derivation(FactoryGirl.attributes_for(:story, title: "Translated_story3", language_id: telugu.id).slice!(:id), new_user, new_user, "translated")
      #translated_story3.save!
      #rating = FactoryGirl.create(:reviewer_comment, :user_id => new_user.id, :story_id => translated_story3.id, :language_id => telugu.id)
      Story.reindex
      expect(Story.count).to eq(5)

      #selected source language English and target language Telugu
      # arguments = {:source_language => "Telugu", :target_language => "hindi"}
      # get :books_for_translation, arguments, format: :json
      # expect_json('data.0.language', 'Telugu')
      # expect_json('data.1.language', 'Telugu')

      #source language as English
      arguments = {:source_language => "English"}
      get :books_for_translation, arguments, format: :json
      x = JSON.parse(response.body)['data']
      expect(x.length).to eq(2)
      expect_json('data.0.title', 'org_story1')
      expect_json('data.0.language', 'English')
      expect_json('data.1.title', 'Translated_story2')
      expect_json('data.1.language', 'English')

      #target language as English
      arguments = {:target_language => "English"}
      get :books_for_translation, arguments, format: :json
      x = JSON.parse(response.body)['data']
      expect(x.length).to eq(0)
      expect_json('data', []) #here its should show empty

      #source language as Hindi
      arguments = {:source_language => "Hindi"}
      get :books_for_translation, arguments, format: :json
      x = JSON.parse(response.body)['data']
      expect(x.length).to eq(1)
      expect_json('data.0.title', 'org_story2')
      expect_json('data.*.title', 'org_story2')

      #target language as Hindi
      arguments = {:target_language => "Hindi"}
      get :books_for_translation, arguments, format: :json
      x = JSON.parse(response.body)['data']
      expect(x.length).to eq(2)
      expect_json('data.0.title', 'org_story1')
      expect_json('data.1.title', 'Translated_story1')

      #source language as kannada
      arguments = {:source_language => "Kannada"}
      get :books_for_translation, arguments, format: :json
      expect_json('data.0.title', 'Translated_story1')
      expect_json('data.*.title', 'Translated_story1')

      #target language as Kannada
      arguments = {:target_language => "Kannada"}
      get :books_for_translation, arguments, format: :json
      expect_json('data.0.title', 'org_story2')
      expect_json('data.1.title', 'Translated_story2')

      #selected source language English and target language Hindi
      arguments = {:source_language => "English", :target_language => "Hindi"}
      get :books_for_translation, arguments, format: :json
      expect_json('data.0.title', 'org_story1')
      expect_json('data.*.title', 'org_story1')

      #selected source language Hindi and target language Kannada
      arguments = {:source_language => "Hindi", :target_language => "Kannada"}
      get :books_for_translation, arguments, format: :json
      expect_json('data.0.title', 'org_story2')
      expect_json('data.*.title', 'org_story2')
    end
  end
  context "GET Book search with filters & query" do
    it "Should show all books" do
      org1 = FactoryGirl.create(:org_publisher, id: 1)
      org2 = FactoryGirl.create(:org_publisher, id: 2)
      @pub1= FactoryGirl.create(:publisher_org, :first_name => "Delhi admin", organization_id: org1.id)
      @pub2= FactoryGirl.create(:publisher_org, :first_name => "Hyderabad admin", organization_id: org2.id)
      User.reindex
      Organization.reindex
      story1 = FactoryGirl.create(:level_1_story, title: "Level_1_story", :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:level_2_story, title: "Level_2_story", :status => Story.statuses[:published])
      story3 = FactoryGirl.create(:level_3_story, title: "Level_3_story", :status => Story.statuses[:published])
      story4 = FactoryGirl.create(:story, title: "Publisher Story 1", :authors => [@pub1], :organization_id => org1.id, :status => Story.statuses[:published], :recommended => true)
      Story.reindex
      expect(Story.all.count).to eq(4)
      get :books_search, format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(4)
      expect_json('data.0.title', 'Publisher Story 1')
      expect_json('data.1.title', 'Level_1_story')
      expect_json('data.2.title', 'Level_2_story')
      expect_json('data.3.title', 'Level_3_story')
    end
    it "Should show books with query - Story Title" do
      story1 = FactoryGirl.create(:level_1_story, title: "First Story", :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:level_2_story, title: "Second Story", :status => Story.statuses[:published])
      story3 = FactoryGirl.create(:level_3_story, title: "Third Story", :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(3)
      arguments = {:query => "second"}
      get :books_search, arguments , format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'Second Story')
    end
    it "Should show books with query - English title" do
      kannada = FactoryGirl.create(:kannada)
      story1 = FactoryGirl.create(:story, title: "English Story", :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:story, title: "ಕನ್ನಡ", :language => kannada, :english_title => "Kannada story", :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(2)
      arguments = {:query => "kannada"}
      get :books_search, arguments , format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'ಕನ್ನಡ')
    end
    it "Should show books with query - Author name" do
      user_2 = FactoryGirl.create(:user, :first_name => "New Test")
      story1 = FactoryGirl.create(:story, title: "English Story 1", :authors => [user_2], :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:story, title: "English story 2", :authors => [@user], :english_title => "Kannada story", :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(2)
      arguments = {:query => "New Test"}
      get :books_search, arguments , format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'English Story 1')
    end
    it "Should show books with query - Synopsis" do
      story1 = FactoryGirl.create(:story, title: "English Story 1", :attribution_text => "Sample text", :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:story, title: "English Story 2", :attribution_text => "Original text", :english_title => "Kannada story", :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(2)
      arguments = {:query => "Original"}
      get :books_search, arguments , format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'English Story 2')
    end
    it "Should show books with query - Publisher" do
      org1 = FactoryGirl.create(:org_publisher, id: 1)
      org2 = FactoryGirl.create(:org_publisher, id: 2)
      @pub1= FactoryGirl.create(:publisher_org, :first_name => "Delhi admin", organization_id: org1.id)
      @pub2= FactoryGirl.create(:publisher_org, :first_name => "Hyderabad admin", organization_id: org2.id)
      User.reindex
      Organization.reindex
      story1 = FactoryGirl.create(:story, title: "Publisher Story 1", :authors => [@pub1], :organization_id => org1.id, :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:story, title: "Publisher Story 2", :authors => [@pub2], :organization_id => org2.id, :english_title => "Kannada story", :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(2)
      arguments = {:query => "Hyderabad"}
      get :books_search, arguments , format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'Publisher Story 2')
    end
    it "Should show books with query - Illustrator" do
      user_2 = FactoryGirl.create(:user, :first_name => "New test user")
      @person = FactoryGirl.create(:person, :user => user_2)
      @illustration = FactoryGirl.create(:illustration, :illustrators => [@person])
      create_story({illustration: @illustration, story_title: "Story 2"})

      story1 = FactoryGirl.create(:story, title: "Story 1", :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(2)
      arguments = {:query => "New test"}
      get :books_search, arguments , format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'Story 2')
    end
    it "should not display uploaded stories for content_manager" do # showing only uplished stories
      content_manager = FactoryGirl.create(:content_manager)
      sign_in content_manager
      story1 = FactoryGirl.create(:story, status: :published)
      story2 = FactoryGirl.create(:story, status: :uploaded)
      story3 = FactoryGirl.create(:story, status: :draft)
      Story.reindex
      expect(Story.all.count).to eq(3)
      get :books_search, format: :json
      expect(ok: true)
      expect(JSON.parse(response.body)['data'].length).to eq(1)
    end
    it "should order results as per New arrivals" do
      story1 = FactoryGirl.create(:story, recommended: true, :title => "Story 1", published_at: '2015-07-28 10:25:54')
      story2 = FactoryGirl.create(:story, recommended: true, :title => "Story 2", published_at: '2015-07-27 03:25:54')
      story3 = FactoryGirl.create(:story, recommended: true, :title => "Story 3", published_at: '2015-07-28 11:25:54')
      arguments = {sort: "New Arrivals"}
      Story.reindex
      get :books_search, arguments, format: :json
      expect(ok: true)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
      expect_json('data.0.title', 'Story 3')
      expect_json('data.1.title', 'Story 1')
      expect_json('data.2.title', 'Story 2')
    end
    it "should order results as per Most Read" do
      story1 = FactoryGirl.create(:story, :title => "Story 1", :reads => 50)
      story2 = FactoryGirl.create(:story, :title => "Story 2", :reads => 9)
      story3 = FactoryGirl.create(:story, :title => "Story 3", :reads => 12)
      arguments = {sort: "Most Read"}
      Story.reindex
      get :books_search, arguments, format: :json
      expect(ok: true)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
      expect_json('data.0.title', 'Story 1')
      expect_json('data.1.title', 'Story 3')
      expect_json('data.2.title', 'Story 2')
    end
    it "should order results as per Most Liked" do
      story1 = FactoryGirl.create(:story, :title => "Story 1")
      5.times {story1.liked_by FactoryGirl.create(:user)}
      story2 = FactoryGirl.create(:story, :title => "Story 2")
      10.times {story2.liked_by FactoryGirl.create(:user)}
      story3 = FactoryGirl.create(:story, :title => "Story 3")
      100.times {story3.liked_by FactoryGirl.create(:user)}
      arguments = {sort: "Most Liked"}
      Story.reindex
      get :books_search, arguments, format: :json
      expect(ok: true)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
      expect_json('data.0.title', 'Story 3')
      expect_json('data.1.title', 'Story 2')
      expect_json('data.2.title', 'Story 1')
    end
    it "Should show books with applied filter - Reading levels" do
      story1 = FactoryGirl.create(:level_1_story, title: "Level_1_story", :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:level_2_story, title: "Level_2_story", :status => Story.statuses[:published])
      story3 = FactoryGirl.create(:level_3_story, title: "Level_3_story", :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(3)
      arguments = {:levels => [2]}
      get :books_search, arguments , format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'Level_2_story')
    end
    it "Should show books with applied filter - Languages" do
      english = FactoryGirl.create( :english)
      kannada = FactoryGirl.create( :kannada)
      hindi = FactoryGirl.create( :hindi)
      story1 = FactoryGirl.create(:story, title: "English_story", language: english, :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:story, title: "Kannada_story", language: kannada, :status => Story.statuses[:published])
      story3 = FactoryGirl.create(:story, title: "Hindi_story", language: hindi, :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(3)
      arguments = {:languages => ["Hindi"]}
      get :books_search, arguments , format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'Hindi_story')
    end
    it "Should show books with applied filter - Categories" do
      english = FactoryGirl.create(:english)
      cat_1 = FactoryGirl.create(:story_category, name:  "cat_1")
      cat_2 = FactoryGirl.create(:story_category, name:  "cat_2")
      story1 = FactoryGirl.create(:story, title: "Cat_2_story",language: english, categories: [cat_2], :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:story, title: "Cat_2_story", language: english, categories: [cat_2], :status => Story.statuses[:published])
      story3 = FactoryGirl.create(:story, title: "Cat_1_story", language: english, categories: [cat_1], :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(3)
      arguments = {:categories => [cat_1.name]}
      get :books_search, arguments, format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'Cat_1_story')
    end
    it "Should show books with applied filter - Publishers" do
      org1 = FactoryGirl.create(:org_publisher, id: 1)
      org2 = FactoryGirl.create(:org_publisher, id: 2)
      org_story1 = FactoryGirl.create(:story, title: "Org_story1", :status => Story.statuses[:published], :organization_id => 1 )
      org_story2 = FactoryGirl.create(:story, title: "Org_story2", :status => Story.statuses[:published], :organization_id => 2 )
      story1 = FactoryGirl.create(:story, title: "Community story", :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(3)
      arguments = {:publishers => [org1.organization_name]}
      get :books_search, arguments , format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'Org_story1')
    end
    it "Should show books with query - Language" do
      english = FactoryGirl.create( :english)
      kannada = FactoryGirl.create( :kannada)
      hindi = FactoryGirl.create( :hindi)
      story1 = FactoryGirl.create(:story, title: "English_story", language: english, :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:story, title: "Kannada_story", language: kannada, :status => Story.statuses[:published])
      story3 = FactoryGirl.create(:story, title: "Hindi_story", language: hindi, :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(3)
      arguments = {:query => "Hindi"}
      get :books_search, arguments , format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'Hindi_story')
    end
    it "Should show books with query - Tags" do
      kannada = FactoryGirl.create( :kannada)
      hindi = FactoryGirl.create( :hindi)
      story1 = FactoryGirl.create(:story, title: "Hindi_story1", language: hindi, tag_list: "New Tag", :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:story, title: "Hindi_story2", language: hindi, tag_list: "Old Tag", :status => Story.statuses[:published])
      story3 = FactoryGirl.create(:story, title: "Kannada_story", language: kannada, :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(3)
      arguments = {:tags => ["Old Tag"]}
      get :books_search, arguments , format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'Hindi_story2')
    end
    it "Should show books with query - Language & Tags" do
      kannada = FactoryGirl.create( :kannada)
      hindi = FactoryGirl.create( :hindi)
      english = FactoryGirl.create( :english)
      story1 = FactoryGirl.create(:story, title: "Hindi story", language: hindi, :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:story, title: "Kannada story", language: kannada, tag_list: "Tag", :status => Story.statuses[:published])
      story3 = FactoryGirl.create(:story, title: "English story", language: english, :status => Story.statuses[:published])
      Story.reindex
      expect(Story.all.count).to eq(3)
      arguments = {:query => "hindi"}
      get :books_search, arguments, format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(1)
      expect_json('data.0.title', 'Hindi story')
    end
  end
  context "GET People search" do
    it "Should show all people" do
      org1 = FactoryGirl.create(:org_publisher, id: 1)
      org2 = FactoryGirl.create(:org_publisher, id: 2)
      @pub1= FactoryGirl.create(:publisher_org, :first_name => "Delhi admin", organization_id: org1.id)
      @pub2= FactoryGirl.create(:publisher_org, :first_name => "Hyderabad admin", organization_id: org2.id)
      user = FactoryGirl.create(:user)
      story1 = FactoryGirl.create(:level_1_story, title: "Level_1_story", :status => Story.statuses[:published])
      story2 = FactoryGirl.create(:level_2_story, title: "Level_2_story", :status => Story.statuses[:published])
      story3 = FactoryGirl.create(:level_3_story, title: "Level_3_story", :status => Story.statuses[:published])
      story4 = FactoryGirl.create(:story, title: "Publisher Story 1", :authors => [@pub1], :organization_id => org1.id, :status => Story.statuses[:published], :recommended => true)
      story = FactoryGirl.create(:story, title: "Story", :authors => [user], :status => Story.statuses[:published])
      User.reindex
      Story.reindex
      expect(Story.all.count).to eq(5)
      get :people_search, format: :json
      expect(JSON.parse(response.body)['data'].length).to eq(5)
    end
  end
end
