require 'rails_helper'
require 'spec_helper'

describe Api::V1::ListsController, :type => :controller do

  render_views
  before(:each) do
    @user= FactoryGirl.create(:user)
    @list_category = FactoryGirl.create(:list_category)
  end

  let(:json) { JSON.parse(response.body) }
  context "POST/Create List" do
    it "should create a list with title as myLibrary once the user created" do
      sign_in @user
      expect(List.count).to eq(1)
      user_list = List.find_by_user_id( @user.id)
      expect(user_list.title).to eq("My Bookshelf")
    end
    it "should create a list with title" do
      sign_in @user
      attributes = {:title => "My First List", format: :json}
      post :create, attributes
      List.reindex
      expect_status(200)
      expect(response).to have_http_status(:ok)
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("title","id","count","liked","likeCount", "readCount","canDelete","author","description","slug","books", "categories")
      expect(expect_json('data.title', "My First List")).to eq(true)
      expect(expect_json('data.count', 0)).to eq(true)
      expect_json('data.liked', false)
      expect_json('data.readCount', 0)
      expect_json('data.canDelete', true)
      expect(expect_json('data.author.name', 'User1 User Last name 1')).to eq(true)
      x = JSON.parse(response.body)["data"]["author"]["slug"]
      expect(x).to end_with("user1-user-last-name-1")
      x = JSON.parse(response.body)["data"]["author"]["profileImage"]
      expect(x).to end_with("/assets/profile_image.svg")
      expect_json('data.description', nil)
      expect_json('data.categories', [])
      x = JSON.parse(response.body)["data"]["slug"]
      expect(x).to end_with("-my-first-list")
      expect_json('data.books.0', nil)
      expect(List.count).to eq(2)
    end
    it "should create a list with title and description" do
      sign_in @user
      attributes = {:title => "My First List", :description => "List Description", format: :json}
      post :create, attributes
      List.reindex
      expect(expect_json('data.title', "My First List")).to eq(true)
      expect(expect_json('data.description','List Description')).to eq(true)
    end
    it "should raise exception if title is not supplied" do
      sign_in @user
      attributes = {:description => "test"}
      expect { post :create, attributes, format: :json }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
  context "SHOW/GET List" do
    it "should show the list" do
      sign_in @user
      list1 = FactoryGirl.create(:list, user: @user)
      stories = FactoryGirl.create_list(:story, 5)
      List.reindex
      Story.reindex
      stories.each do |story|
        post :add_story, :id => list1.id, :story_id => story.id, format: :json
      end
      get :show,:id => list1.id,  format: :json
      expect_status(200)
      expect_json_keys([:ok, :data])
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("title","id","count","liked", "likeCount", "readCount","canDelete","author","description","slug","books", "organisation", "categories")
      expect_json(ok: true)
      categories_array = []
      list1.categories.each {|cat| categories_array << cat.name }
      expect_json('data', title: list1.title, description: list1.description, count: stories.count)
    end
  end
  context "INDEX/GET List" do
    it "should show all the lists" do
      sign_in @user
      org1 = FactoryGirl.create(:org_publisher, id: 1)
      @pub1= FactoryGirl.create(:publisher_org, organization_id: org1.id)
      list1 = FactoryGirl.create(:list, user: @user,:organization_id => org1.id)
      listview = FactoryGirl.create_list(:list_view, 5, :list => list1, user: @user)
      listlike = FactoryGirl.create_list(:list_like, 4, :list => list1, user: @user)
      english = FactoryGirl.create(:english)
      story = FactoryGirl.create(:level_1_story,language: english, :title => "Original Story", :authors => [@user], :status => Story.statuses[:published], :synopsis => "Story Synopsis")
      liststory = FactoryGirl.create(:lists_story, :list => list1, :story => story)
      Story.reindex
      List.reindex
      post :add_story, :id => list1.id, :story_id => story.id, format: :json
      get :index, format: :json
      expect_status(200)
      expect_json_keys([:ok, :metadata, :data])
      expect(JSON.parse(response.body)['metadata'].keys).to contain_exactly("hits","per_page","page","total_pages")
      expect_json('metadata', hits: 3, per_page: 10, page: 1, total_pages:1)
      expect(JSON.parse(response.body)['data'][0].keys).to contain_exactly("_index","_type","_id","_score","sort","id","title","description","slug","status","categories","likes","views","created_at","author","author_id","author_slug","organization_name","organization_id","organization_slug","organization_profile_image", "organization_type", "count","books","languages","reading_levels","can_delete", "stories_tips")
      # Because there will be a default list "My Library" for every new user created.
      expect_json_sizes(data: 3)

      expect_json('data.0.likes', 4)
      expect_json('data.0.views', 5)
      expect(expect_json('data.0.organization_name', 'org_publisher_name 1')).to eq(true)
      x = JSON.parse(response.body)["data"][0]["organization_slug"]
      expect(x).to end_with("org_publisher_name-1")
      x = JSON.parse(response.body)["data"][0]["organization_profile_image"]
      expect(x).to end_with("/assets/original/missing.png")
      expect_json('data.0.stories_tips', ["Test story tip"])
    end
  end
  context "UPDATE List" do
    let(:list) { FactoryGirl.create(:list, user: @user) }
    it "Same User should be able to update list title and description" do
      sign_in @user
      List.reindex
      attributes = {:title => "Second List Title", :description => "2nd List Description"}
      put :update, :id => list.id, :list => attributes, format: :json
      expect_status(200)
      expect(List.find(list.id).title).to eq("Second List Title")
    end
    it "Different User should not be able to update list title and description" do
      @diff_user= FactoryGirl.create(:user)
      sign_in @diff_user
      List.reindex
      attributes = {:title => "diff user Second List Title", :description => "diff user 2nd List Description"}
      put :update, :id => list.id, :list => attributes, format: :json
      expect_status(401)
    end
  end
  context "DELETE List" do
    let(:list_of_lists) {FactoryGirl.create_list(:list, 4, user: @user) }
    it "should delete the list with provided list id" do
      sign_in @user
      List.reindex
      expect(List.all.count).to eq(1)
      delete :destroy, :id => list_of_lists[1].id
      expect_status(200)
      # Default list created when user is created is also counted.
      expect(List.all.count).to eq(4)
    end
    it "should not be able to delete the list if its different user" do
      @diff_user= FactoryGirl.create(:user)
      sign_in @diff_user
      list_of_lists = FactoryGirl.create_list(:list, 4, user: @user)
      List.reindex
      delete :destroy, :id => list_of_lists[1].id
      expect_status(401)
      expect_json_keys([:ok, :data])
      expect(json).to eq("ok"=>false, "data"=>{"errorCode"=>401, "errorMessage"=>"You are not authorized to perform this action."})
      expect(response).to have_http_status(:unauthorized)
      # Default list created when user is created is also counted.
      expect(List.all.count).to eq(6)
    end
  end
  context "CREATE List and ADD a Story" do
    it "should add a story to the list" do
      sign_in @user
      list1 = FactoryGirl.create(:list, user: @user)
      story1 = FactoryGirl.create(:story)
      lists_story1 = FactoryGirl.create(:lists_story, :story_id => story1.id, :list_id => list1.id)
      List.reindex
      Story.reindex
      attributes = {:id => story1.id}
      post :add_story, :id => list1.id, :story_id => story1.id
      get :show,:id => list1.id,  format: :json
      expect(ListsStory.where(:story => story1, :list => list1).count).to eq(1)
      expect_status(200)
      expect(expect_json('data.count', 1)).to eq(true)
      expect_json('data.readCount', 1)
      expect(JSON.parse(response.body)['data']['books'][0].keys).to contain_exactly("title","id","language","level","slug","synopsis","usageInstructions","coverImage","authors")
      expect(expect_json('data.books.0.title', 'Title1')).to eq(true)
      expect(expect_json('data.books.0.language', 'Language 1')).to eq(true)
      expect(expect_json('data.books.0.level', '1')).to eq(true)
      x = JSON.parse(response.body)["data"]["books"][0]["slug"]
      expect(x).to end_with("-english-title1")
      expect(expect_json('data.books.0.synopsis', 'Synopsis 1')).to eq(true)
      expect(JSON.parse(response.body)['data']['books'][0]['usageInstructions'].keys).to contain_exactly("html","txt")
      expect_json('data.books.0.usageInstructions.html', "<p>Test story tip</p>")
      expect(expect_json('data.books.0.usageInstructions.txt',"Test story tip")).to eq(true)
      expect(JSON.parse(response.body)['data']['books'][0]['coverImage'].keys).to contain_exactly("aspectRatio","cropCoords","sizes")
      expect(JSON.parse(response.body)['data']['books'][0]['coverImage']['sizes'][0].keys).to contain_exactly("height","width","url") 
      expect(JSON.parse(response.body)['data']['books'][0]['authors'][0].keys).to contain_exactly("slug","name")
      x = JSON.parse(response.body)['data']['books'][0]['authors'][0]['slug']
      expect(x).to end_with("user2-user-last-name-2")
      expect(expect_json('data.books.0.authors.0.name',"User2 User Last name 2")).to eq(true)
    end
    it "should not add a story to the list if its logged in with different user" do
      @diff_user= FactoryGirl.create(:user)
      sign_in @diff_user
      list1 = FactoryGirl.create(:list, user: @user)
      story1 = FactoryGirl.create(:story)
      lists_story1 = FactoryGirl.create(:lists_story, :story_id => story1.id, :list_id => list1.id)
      List.reindex
      Story.reindex
      attributes = {:id => story1.id}
      post :add_story, :id => list1.id, :story_id => story1.id
      expect_status(401)
      expect_json_keys([:ok, :data])
      expect(json).to eq("ok"=>false, "data"=>{"errorCode"=>401, "errorMessage"=>"You are not authorized to perform this action."})
      expect(response).to have_http_status(:unauthorized)
    end
  end
  context "DELETE Story From List" do
    it "should delete a story with provided story id with List Length  = 1" do
      sign_in @user
      list1 = FactoryGirl.create(:list, user: @user)
      story1 = FactoryGirl.create(:story, :status => Story.statuses[:published])
      List.reindex
      Story.reindex
      attributes = {:id => story1.id}
      post :add_story, :id => list1.id, :story_id => story1.id, format: :json
      expect_status(200)
      expect_json(ok: true)
      expect_json_keys([:ok, :data])
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("stories")
      expect(ListsStory.where(:story => story1, :list => list1).count).to eq(1)
      delete :remove_story, :id => list1.id, :story_id => story1.id
      expect(ListsStory.where(:story => story1, :list => list1).count).to eq(0)
      expect_status(200)
    end
    it "should not delete a story if its login with different user" do
      @diff_user= FactoryGirl.create(:user)
      sign_in @diff_user
      list1 = FactoryGirl.create(:list, user: @user)
      story1 = FactoryGirl.create(:story, :status => Story.statuses[:published])
      List.reindex
      Story.reindex
      attributes = {:id => story1.id}
      post :add_story, :id => list1.id, :story_id => story1.id, format: :json
      expect_status(401)
      expect_json_keys([:ok, :data])
      expect(json).to eq("ok"=>false, "data"=>{"errorCode"=>401, "errorMessage"=>"You are not authorized to perform this action."})
      expect(response).to have_http_status(:unauthorized)
    end
    it "should delete a story from middle with List Length = 5 and maintain position" do
      sign_in @user
      list = FactoryGirl.create(:list, user: @user)
      stories = FactoryGirl.create_list(:story, 5)
      List.reindex
      Story.reindex
      stories.each do |story|
        post :add_story, :id => list.id, :story_id => story.id, format: :json
      end
      delete :remove_story, :id => list.id, :story_id => stories[2].id # Delete story from between
      expect(ListsStory.where(:list => list).order( 'position ASC' ).last.position).to eq(4)
    end
  end
  context "POST List Likes" do
    it "should show the list likes for the list" do
      sign_in @user
      list1 = FactoryGirl.create(:list, user: @user)
      story1 = FactoryGirl.create(:story, :status => Story.statuses[:published])
      List.reindex
      Story.reindex
      post :list_like, :id => list1.id, format: :json
      expect_json('data.liked', true)
      expect(ListLike.where(:list => list1, :user => @user).count).to eq(1)
      expect_status(200)
      expect(response).to have_http_status(:ok)
    end
  end
  context "DELETE List Likes" do
    it "should delete the list likes from the list" do
      sign_in @user
      list_like1 = FactoryGirl.create(:list, user: @user)
      story1 = FactoryGirl.create(:story, :status => Story.statuses[:published])
      List.reindex
      Story.reindex
      post :list_like, :id => list_like1.id, format: :json
      expect(ListLike.where(:list => list_like1, :user => @user).count).to eq(1)
      post :list_unlike, :id => list_like1.id, format: :json
      expect_json('data.liked', false)
      expect(ListLike.where(:list => list_like1, :user => @user).count).to eq(0)
      expect_status(200)
      expect(response).to have_http_status(:ok)
    end
  end
  context "rearrange_story" do
    it "should rearrange_story" do
      sign_in @user
      list = FactoryGirl.create(:list, user: @user)
      stories = FactoryGirl.create_list(:story, 5)
      List.reindex
      Story.reindex
      stories.each do |story|
        post :add_story, :id => list.id, :story_id => story.id
      end
      post :rearrange_story, :id => list.id, :story_id => stories[0].id, :position => 3, format: :json
      expect(ListsStory.where(list: list,story: stories[0]).first.position).to eq(3)
      expect_status(200)
      expect(response).to have_http_status(:ok)
    end
    it "should not rearrange_story if its logged in with different user" do
      @diff_user= FactoryGirl.create(:user)
      sign_in @diff_user
      list = FactoryGirl.create(:list, user: @user)
      stories = FactoryGirl.create_list(:story, 5)
      List.reindex
      Story.reindex
      stories.each do |story|
        post :add_story, :id => list.id, :story_id => story.id
      end
      expect_json_keys([:ok, :data])
      expect(json).to eq("ok"=>false, "data"=>{"errorCode"=>401, "errorMessage"=>"You are not authorized to perform this action."})
      expect(response).to have_http_status(:unauthorized)
      post :rearrange_story, :id => list.id, :story_id => stories[0].id, :position => 3, format: :json
    end
  end
  context "Search" do
    it "should search the list with given query" do
      sign_in @user
      list1 = FactoryGirl.create(:list, user: @user, :title=> "List with 1 English Story" )
      list2 = FactoryGirl.create(:list, user: @user, :title=> "List with 1 Kannada Story" )
      list3 = FactoryGirl.create(:list, user: @user, :title=> "List with 1 Hindi Story" )
      english = FactoryGirl.create( :english)
      kannada = FactoryGirl.create( :kannada)
      hindi = FactoryGirl.create( :hindi)
      story1 = FactoryGirl.create(:level_1_story,language: english,:status => Story.statuses[:published])
      story2 = FactoryGirl.create(:level_2_story,language: kannada,:status => Story.statuses[:published])
      story3 = FactoryGirl.create(:level_3_story,language: hindi,:status => Story.statuses[:published])
      post :add_story, :id => list1.id, :story_id => story1.id
      post :add_story, :id => list2.id, :story_id => story2.id
      post :add_story, :id => list3.id, :story_id => story3.id
      List.reindex
      arguments = {:search => {:languages => ["Kannada", "Hindi"], :reading_levels => ["2","1"]} }
      get :index, arguments, format: :json
      expect_json('data.0.title', 'List with 1 Kannada Story')
      expect(response.body).should_not match("List with 1 Hindi Story")
      expect(response.body).should_not match("List with 1 English Story")
      expect_status(200)
    end
  end
  context "Filters" do
    it "should filter the list with given parameters" do
      sign_in @user
      english = FactoryGirl.create(:english)
      hindi = FactoryGirl.create(:hindi)
      funny = FactoryGirl.create(:list_category, :name => "Funny", :translated_name => "Translated Funny")
      fiction = FactoryGirl.create(:list_category, :name => "Fiction", :translated_name => "Translated Fiction")
      eng_story = FactoryGirl.create(:story, :language => english, :status => Story.statuses[:published])
      hin_story = FactoryGirl.create(:level_2_story, :language => hindi, :status => Story.statuses[:published])
      list1 = FactoryGirl.create(:list, user: @user, :title => "List1", :categories => [funny])
      list2 = FactoryGirl.create(:list, user: @user, :title => "List2", :categories => [fiction])
      List.reindex
      Story.reindex
      post :add_story, :id => list1.id, :story_id => eng_story.id
      expect_status(200)
      post :add_story, :id => list2.id, :story_id => hin_story.id
      expect_status(200)
      get :filters, format: :json
      expect_json(ok: true)
      expect(JSON.parse(response.body).keys).to contain_exactly('ok', 'data')
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('filters', 'sortOptions')
      expect(JSON.parse(response.body)['data']['filters'][0].keys).to contain_exactly('name', 'queryKey', 'queryValues')
      expect_json('data.filters.0.name', 'Category')
      expect_json('data.filters.0.queryKey', 'category')
      expect_json('data.filters.0.queryValues.0.name', 'Translated Activity Books1')
      expect_json('data.filters.0.queryValues.0.queryValue', 'Activity Books1')
      expect_json('data.filters.0.queryValues.1.name', 'Translated Funny')
      expect_json('data.filters.0.queryValues.1.queryValue', 'Funny')
      expect_json('data.filters.0.queryValues.2.name', 'Translated Fiction')
      expect_json('data.filters.0.queryValues.2.queryValue', 'Fiction')
      expect(JSON.parse(response.body)['data']['sortOptions'][0].keys).to contain_exactly('name', 'queryValue')
      expect_json('data.sortOptions.0.name', 'Most Liked')
      expect_json('data.sortOptions.0.queryValue', 'likes')
      expect_json('data.sortOptions.1.name', 'Most Viewed')
      expect_json('data.sortOptions.1.queryValue', 'views')
      expect_json('data.sortOptions.2.name', 'New Arrivals')
      expect_json('data.sortOptions.2.queryValue', 'published_at')
      expect_status(200)
    end
  end
  describe "Validating the api's without user authentication" do
    context "POST/Create List without authentication" do
      it "should respond as user need to sign in or sign up before continuing to create list" do
        attributes = {:title => "My list", :description => "test"}
        post :create, :list => attributes, format: :json
        expect_status(401)
        expect(json).to eq("error"=>"You need to sign in or sign up before continuing.")
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "SHOW/GET List without authentication" do
      it "should show the list without authentication" do
        list1 = FactoryGirl.create(:list, user: @user)
        List.reindex
        get :index, format: :json
        expect_status(200)
        expect(response).not_to have_http_status(:unauthorized)
      end
    end
    context "UPDATE List without authentication" do
      it "should respond as user need to sign in or sign up before continuing to update the list" do
        l = FactoryGirl.create(:list, user: @user)
        attributes = {:title => "Second List", :description => "Second List"}
        put :update, :id => l.id, :list => attributes, format: :json
        expect_status(401)
        expect(json).to eq("error"=>"You need to sign in or sign up before continuing.")
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "DELETE List without authentication" do
      it "should respond as user need to sign in or sign up before continuing to delete list" do
        list1 = FactoryGirl.create(:list, user: @user)
        list2 = FactoryGirl.create(:list, user: @user)
        delete :destroy, :id => list2.id, format: :json
        expect_status(401)
        expect(json).to eq("error"=>"You need to sign in or sign up before continuing.")
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "CREATE List and ADD a Story without authentication" do
      it "should respond as user need to sign in or sign up before continuing to add story to list" do
        list1 = FactoryGirl.create(:list, user: @user)
        story1 = FactoryGirl.create(:story)
        attributes = {:id => story1.id}
        post :add_story, :id => list1.id, :story_id => story1.id, format: :json
        expect_status(401)
        expect(json).to eq("error"=>"You need to sign in or sign up before continuing.")
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "DELETE Story without authentication" do
      it "should respond as user need to sign in or sign up before continuing to delete story" do
        list1 = FactoryGirl.create(:list, user: @user)
        story1 = FactoryGirl.create(:story, :status => Story.statuses[:published])
        attributes = {:id => story1.id}
        post :add_story, :id => list1.id, :story_id => story1.id, format: :json
        expect_status(401)
        delete :remove_story, :id => list1.id, :story_id => story1.id, format: :json
        expect_status(401)
        expect(json).to eq("error"=>"You need to sign in or sign up before continuing.")
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "List Likes without authentication" do
      it "should respond as user need to sign in or sign up before continuing to see the list likes" do
        list1 = FactoryGirl.create(:list, user: @user)
        story1 = FactoryGirl.create(:story, :status => Story.statuses[:published])
        post :list_like, :id => list1.id, format: :json
        expect_status(401)
        expect(json).to eq("error"=>"You need to sign in or sign up before continuing.")
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "List Search without authentication" do
      it "should search the list and display the result with given parameters"
        #pending -  code change required as list categories is collecting data from story categories
        #do
        #sign_in @user
        #list1 = FactoryGirl.create(:list, user: @user, :title=> "List with 1 English Story" )
        #list2 = FactoryGirl.create(:list, user: @user, :title=> "List with Kannada story" )
        #list3 = FactoryGirl.create(:list, user: @user, :title=> "List with Hindi Story" )
        #english = FactoryGirl.create( :english)
        #kannada = FactoryGirl.create( :kannada)
        #hindi = FactoryGirl.create( :hindi)
        #story1 = FactoryGirl.create(:level_1_story,language: english,:status => Story.statuses[:published])
        #story2 = FactoryGirl.create(:level_2_story,language: kannada,:status => Story.statuses[:published])
        #story3 = FactoryGirl.create(:level_3_story,language: hindi,:status => Story.statuses[:published])
        ##[story1, story2, story3].each do |story|
        ##  post :add_story, :id => list1.id, :story_id => story.id
        ##end
        #post :add_story, :id => list2.id, :story_id => story2.id
        #post :add_story, :id => list3.id, :story_id => story3.id
        #List.reindex
        #sign_out @user
        ##arguments = {:search => {:languages => ["English"], :reading_levels => ["1"]} }
        #arguments = {:search => {:languages => ["Kannada"], :reading_levels => ["2"]} }
        #get :index, arguments, format: :json
        #expect_status(200)
      #end
    end
  end
end
