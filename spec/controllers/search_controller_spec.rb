# encoding: utf-8
require 'rails_helper'
require 'securerandom'

describe SearchController, :type => :controller do

  describe "POST search" do
#    it "should show all stories when no query is specified" do
#      story1 = FactoryGirl.create(:story)
#      story2 = FactoryGirl.create(:story)
#      Story.reindex
#
#      post :search
#
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be true
#    end
#
#    it "should order results as per new arrival" do
#      story1 = FactoryGirl.create(:story, recommended: true, published_at: '2015-07-28 10:25:54')
#      story2 = FactoryGirl.create(:story, recommended: true, published_at: '2015-07-27 03:25:54')
#      story3 = FactoryGirl.create(:story, recommended: true, published_at: '2015-07-28 11:25:54')
#      search_params = {sort: { published_at: {order: :desc} }}
#      Story.reindex
#      post :search, search: search_params
#      expected_titles = [story3,story1,story2].map(&:title)
#      expect(assigns(:results).collect(&:title)).to eq(expected_titles)
#    end
#
#    it "should order results as per recommendation, reads and likes for no query term specified" do
#      story1 = FactoryGirl.create(:story, recommended: nil, reads: 10)
#      10.times {story1.liked_by FactoryGirl.create(:user)}
#      story2 = FactoryGirl.create(:story, recommended: true,  reads: 100)
#      1.times {story2.liked_by FactoryGirl.create(:user)}
#      story3 = FactoryGirl.create(:story, recommended: nil, reads: 3)
#      2.times {story3.liked_by FactoryGirl.create(:user)}
#      story4 = FactoryGirl.create(:story, recommended: true,  reads: 3)
#      1.times {story4.liked_by FactoryGirl.create(:user)}
#      story5 = FactoryGirl.create(:story, recommended: nil, reads: 1000)
#      100.times {story5.liked_by FactoryGirl.create(:user)}
#      story6 = FactoryGirl.create(:story, recommended: nil, reads: 0)
#      Story.reindex
#      post :search
#      expected_titles = [story2,story4,story5,story1,story3,story6].map(&:title)
#      expect(assigns(:results).collect(&:title)).to eq(expected_titles)
#    end
#
#    it "should order results as per specified criteria" do
#      story1 = FactoryGirl.create(:story, recommended: nil, reads: 10)
#      10.times {story1.liked_by FactoryGirl.create(:user)}
#      story2 = FactoryGirl.create(:story, recommended: true,  reads: 100)
#      1.times {story2.liked_by FactoryGirl.create(:user)}
#      Story.reindex
#
#      search_params = {query: "", languages: [], categories: [], organizations: [], reading_levels: [], sort: { reads: {order: :desc} }}
#      post :search, search: search_params
#      expected_titles = [story2,story1].map(&:title)
#      expect(assigns(:results).collect(&:title)).to eq(expected_titles)
#
#      search_params = {query: "", languages: [], categories: [], organizations: [], reading_levels: [], sort: { recommended: {order: :desc} }}
#      post :search, search: search_params
#      expected_titles = [story1,story2].map(&:title)
#      expect(assigns(:results).collect(&:title)).to eq(expected_titles)
#    end
#
#    it "should search by title" do
#      story1 = FactoryGirl.create(:story, title: 'My school ' + SecureRandom.uuid)
#      story2 = FactoryGirl.create(:story, title: 'my home ' + SecureRandom.uuid)
#      Story.reindex
#
#      search_params = {query: "my", languages: [], categories: [], organizations: [], reading_levels: []}
#      post :search, search: search_params
#
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:synopsis).include?(story1.synopsis)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be true
#      expect(assigns(:results).collect(&:synopsis).include?(story2.synopsis)).to be true
#    end
#
#    it "should search by english title" do
#      story1 = FactoryGirl.create(:story, title: 'ಕನ್ನಡ ' + SecureRandom.uuid, english_title: 'Kannada')
#      story2 = FactoryGirl.create(:story, title: 'हिंदी ' + SecureRandom.uuid, english_title: 'Hindi')
#      Story.reindex
#
#      search_params = {query: "Kannada", languages: [], categories: [], organizations: [], reading_levels: []}
#      post :search, search: search_params
#
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be false
#    end
#
#    it "should search by author" do
#      fav_author = FactoryGirl.create(:user, name: 'My Favorite Author')
#      story1 = FactoryGirl.create(:story, authors: [fav_author])
#      story2 = FactoryGirl.create(:story)
#      Story.reindex
#
#      search_params = {query: "Favorite", languages: [], categories: [], organizations: [], reading_levels: [],bulk_options: [], target_languages: []}
#      post :search, search: search_params
#
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be false
#      expect(assigns(:search_params)).to eql({'query' => 'Favorite', 'languages'=>[], 'categories'=>[], 'organizations'=>[], 'reading_levels'=>[], 'derivation_type'=>nil,'bulk_options' => [], 'target_languages'=>[]})
#      expect(assigns(:filters)).to eql({status: [:published]})
#    end
#
#    it "should search by synopsis" do
#      story1 = FactoryGirl.create(:story, synopsis: 'My school ' + SecureRandom.uuid, )
#      story2 = FactoryGirl.create(:story, synopsis: 'my home ' + SecureRandom.uuid)
#      story3 = FactoryGirl.create(:story, synopsis: 'Some other text' + SecureRandom.uuid)
#      Story.reindex
#
#      search_params = {query: "my", languages: [], categories: [], organizations: [], reading_levels: [], derivation_type: []}
#      post :search, search: search_params
#
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story3.title)).to be false
#    end
#
#    it "should search by publisher" do
#      story1 = FactoryGirl.create(:story, organization: FactoryGirl.create(:organization, organization_name: 'Pratham Books'))
#      story2 = FactoryGirl.create(:story, organization: FactoryGirl.create(:organization, organization_name: 'Parag Publishers'))
#      story3 = FactoryGirl.create(:story)
#      Story.reindex
#
#      search_params = {query: "pratham books", languages: [], categories: [], organizations: [], reading_levels: [], derivation_type: []}
#      post :search, search: search_params
#
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be false
#      expect(assigns(:results).collect(&:title).include?(story3.title)).to be false
#    end
#
#    it "should search by content" do
#      story1 = FactoryGirl.create(:story)
#      FactoryGirl.create(:story_page, story: story1, content: 'My school is the best')
#      story2 = FactoryGirl.create(:story)
#      FactoryGirl.create(:story_page, story: story2, content: 'I love my grand father')
#      Story.reindex
#
#      search_params = {query: "school", languages: [], categories: [], organizations: [], reading_levels: [], derivation_type: []}
#      post :search, search: search_params
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be false
#
#      search_params = {query: "love grand", languages: [], categories: [], organizations: [], reading_levels: [], derivation_type: []}
#      post :search, search: search_params
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be false
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be true
#    end
#
#    it "should search by illustrators" do
#      story1 = FactoryGirl.create(:story)
#      page1 = FactoryGirl.create(:story_page, story: story1)
#      generate_illustration_crop(page1, FactoryGirl.create(:illustration, illustrators: [FactoryGirl.create(:person, first_name: 'Poonam',last_name: 'Athalye')]))
#      story2 = FactoryGirl.create(:story)
#      page3 = FactoryGirl.create(:story_page, story: story2)
#      generate_illustration_crop(page3, FactoryGirl.create(:illustration, illustrators: [FactoryGirl.create(:person, first_name: 'Sanjay',last_name: 'Sarkar')]))
#      Story.reindex
#
#      search_params = {query: "Sanjay", languages: [], categories: [], organizations: [], reading_levels: [], derivation_type: []}
#      post :search, search: search_params
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be false
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be true
#
#      search_params = {query: "athalye", languages: [], categories: [], organizations: [], reading_levels: [], derivation_type: []}
#      post :search, search: search_params
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be false
#    end
#
#    it "should search by language" do
#      language = FactoryGirl.create(:language, name: SecureRandom.uuid.gsub('-', ''))
#      another_language = FactoryGirl.create(:language, name: SecureRandom.uuid.gsub('-', ''))
#      story1 = FactoryGirl.create(:story, language: language)
#      story2 = FactoryGirl.create(:story, language: another_language)
#      Story.reindex
#
#      search_params = {query: language.name, languages: [], categories: [], organizations: [], reading_levels: [], derivation_type: []}
#      post :search, search: search_params
#
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be false
#    end
#
#    it "should boost content based on the fields where the match is found" do
#      story1 = FactoryGirl.create(:story, synopsis: 'My school is the best')
#      story2 = FactoryGirl.create(:story)
#      FactoryGirl.create(:story_page, story: story2, content: 'My school is the best')
#      story3 = FactoryGirl.create(:story, title: 'My school is the best')
#      story4 = FactoryGirl.create(:story, english_title: 'My school is the best')
#      Story.reindex
#
#      search_params = {query: "my school", languages: [], categories: [], organizations: [], reading_levels: [], derivation_type: []}
#      post :search, search: search_params
#      expect(
#        find_by_id(assigns(:results), story1)._score > find_by_id(assigns(:results), story2)._score)
#      .to be true
#      expect(
#        find_by_id(assigns(:results), story3)._score > find_by_id(assigns(:results), story1)._score)
#      .to be true
#      expect(
#        find_by_id(assigns(:results), story3)._score > find_by_id(assigns(:results), story4)._score)
#      .to be true
#    end
#
#    def find_by_id(results, story)
#      results.select{|result| result.id == story.id}.first
#    end
#
#    it "should filter by language" do
#      language1 = FactoryGirl.create(:language)
#      language2 = FactoryGirl.create(:language)
#      language1_story = FactoryGirl.create(:story, title: 'Title 1 ' + SecureRandom.uuid, language: language1)
#      language2_story = FactoryGirl.create(:story, title: 'Title 2 ' + SecureRandom.uuid, language: language2)
#      Story.reindex
#
#      search_params = {query: 'Title', languages: [language1.name, ''], categories: [], organizations: [], reading_levels: [], derivation_type: nil, bulk_options: [], target_languages: []}
#      post :search, search: search_params
#
#      expect(assigns(:results).collect(&:title).include?(language1_story.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(language2_story.title)).to be false
#      expect(assigns(:search_params)).to eql({'query'=>'Title', 'languages'=>[language1.name], 'categories'=>[], 'organizations'=>[], 'reading_levels'=>[] , 'derivation_type' =>nil, 'bulk_options' => [], 'target_languages'=>[]})
#      expect(assigns(:filters)).to eql({language: [language1.name], status: [:published]})
#    end
#
#    it "should filter by categories" do
#      category1 = FactoryGirl.create(:story_category)
#      category2 = FactoryGirl.create(:story_category)
#      category1_story = FactoryGirl.create(:story, title: 'Title 1 ' + SecureRandom.uuid, categories: [category1])
#      category2_story = FactoryGirl.create(:story, title: 'Title 2 ' + SecureRandom.uuid, categories: [category2])
#      Story.reindex
#
#      search_params = {query: 'Title', languages: [], categories: [category1.name, ''], organizations: [], reading_levels: [], bulk_options: [], target_languages: []}
#      post :search, search: search_params
#
#      expect(assigns(:results).collect(&:title).include?(category1_story.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(category2_story.title)).to be false
#      expect(assigns(:search_params)).to eql({'query'=>'Title', 'languages'=>[], 'categories'=>[category1.name], 'organizations'=>[], 'reading_levels'=>[], 'derivation_type' => nil, 'bulk_options' => [], 'target_languages'=>[]})
#      expect(assigns(:filters)).to eql({categories: [category1.name], status: [:published]})
#    end
#    it "should filter by publishers" do
#      organization1 = FactoryGirl.create(:organization)
#      organization2 = FactoryGirl.create(:organization)
#      organization1_story = FactoryGirl.create(:story, title: 'Title 1 ' + SecureRandom.uuid, organization: organization1)
#      organization2_story = FactoryGirl.create(:story, title: 'Title 2 ' + SecureRandom.uuid, organization: organization2)
#      Story.reindex
#
#      search_params = {query: 'Title', languages: [], categories: [], organizations: [organization1.organization_name, ''], reading_levels: [], bulk_options: [], target_languages: []}
#      post :search, search: search_params
#
#      expect(assigns(:results).collect(&:title).include?(organization1_story.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(organization2_story.title)).to be false
#      expect(assigns(:search_params)).to eql({'query'=>'Title', 'languages'=>[], 'categories'=>[], 'organizations'=>[organization1.organization_name], 'reading_levels'=>[], 'derivation_type' => nil, 'bulk_options' => [], 'target_languages'=>[]})
#      expect(assigns(:filters)).to eql({organization: [organization1.organization_name], status: [:published]})
#    end
#
#    it "should filter by reading levels" do
#      category1_story = FactoryGirl.create(:story, title: 'Title 1 ' + SecureRandom.uuid, reading_level: '1')
#      category2_story = FactoryGirl.create(:story, title: 'Title 2 ' + SecureRandom.uuid, reading_level: '2')
#      category3_story = FactoryGirl.create(:story, title: 'Title 3 ' + SecureRandom.uuid, reading_level: '3')
#      Story.reindex
#
#      search_params = {query: 'Title', languages: [], categories: [], organizations: [], reading_levels: ['1', '3', ''], bulk_options: [], target_languages: []}
#      post :search, search: search_params
#
#      expect(assigns(:results).collect(&:title).include?(category1_story.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(category2_story.title)).to be false
#      expect(assigns(:results).collect(&:title).include?(category3_story.title)).to be true
#      expect(assigns(:search_params)).to eql({'query'=>'Title', 'languages'=>[], 'categories'=>[], 'organizations'=>[], 'reading_levels'=>['1', '3'], 'derivation_type' => nil, 'bulk_options' => [], 'target_languages'=>[]})
#      expect(assigns(:filters)).to eql({reading_level: ['1', '3'], status: [:published]})
#    end
#
#    it "should paginate search results" do
#      language = FactoryGirl.create(:language)
#      15.times do
#        FactoryGirl.create(:story, language: language)
#      end
#      Story.reindex
#
#      search_params = {languages: [language.name], categories: [], organizations: [], reading_levels: [], derivation_type: [], bulk_options: []}
#      post :search, search: search_params
#
#      expect(assigns(:results).length).to eql(10)
#    end
#
#    it "should display only published stories if user is not logged in or not content_manager or reviewer" do
#      story1 = FactoryGirl.create(:story, status: :published)
#      story2 = FactoryGirl.create(:story, status: :uploaded)
#      story3 = FactoryGirl.create(:story, status: :draft)
#      Story.reindex
#
#      post :search
#
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be false
#      expect(assigns(:results).collect(&:title).include?(story3.title)).to be false
#    end
#
#    it "should not display uploaded stories for content_manager" do
#      content_manager = FactoryGirl.create(:content_manager)
#      sign_in content_manager
#      story1 = FactoryGirl.create(:story, status: :published)
#      story2 = FactoryGirl.create(:story, status: :uploaded)
#      story3 = FactoryGirl.create(:story, status: :draft)
#      Story.reindex
#
#      post :search
#
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be false
#      expect(assigns(:results).collect(&:title).include?(story3.title)).to be false
#    end
#
#    it "should display uploaded stories for reviewer" do
#      reviewer = FactoryGirl.create(:reviewer)
#      reviewer.site_roles = "reviewer"
#      reviewer.save!
#      sign_in reviewer
#      story1 = FactoryGirl.create(:story, status: :published)
#      story2 = FactoryGirl.create(:story, status: :uploaded)
#      story3 = FactoryGirl.create(:story, status: :draft)
#      Story.reindex
#
#      post :search
#
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story3.title)).to be false
#    end
#
#    it "should not display uploaded stories for admin" do
#      admin = FactoryGirl.create(:admin)
#      sign_in admin
#      story1 = FactoryGirl.create(:story, status: :published)
#      story2 = FactoryGirl.create(:story, status: :uploaded)
#      story3 = FactoryGirl.create(:story, status: :draft)
#      Story.reindex
#
#      post :search
#
#      expect(assigns(:results).collect(&:title).include?(story1.title)).to be true
#      expect(assigns(:results).collect(&:title).include?(story2.title)).to be false
#      expect(assigns(:results).collect(&:title).include?(story3.title)).to be false
#    end
#
#    it "should respond that user cannot like story when he is not logged in" do
#      story = FactoryGirl.create(:story)
#      Story.reindex
#
#      xhr :get, :search, format: :json
#      json = JSON.parse(response.body)
#      expect(json['search_results'].select{|result| result['id'] == story.id}.first['can_user_like_story']).to be false
#    end
#
#    it "should respond that user can like story when he is logged in" do
#      story = FactoryGirl.create(:story)
#      Story.reindex
#      sign_in FactoryGirl.create(:user)
#
#      xhr :get, :search, format: :json
#      json = JSON.parse(response.body)
#      expect(json['search_results'].select{|result| result['id'] == story.id}.first['can_user_like_story']).to be true
#    end

  end

end
