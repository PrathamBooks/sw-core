require 'rails_helper'

RSpec.describe DashboardController, :type => :controller do

  before :each do
    @content_manager= FactoryGirl.create(:content_manager)
    @content_manager = FactoryGirl.create(:content_manager)
    @content_manager.site_roles = "content_manager"
    @content_manager.save!
    sign_in @content_manager
  end

  describe "GET index" do
    it "responds with an HTTP 200 status code" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "assigns @stories with uploaded status filter" do
      story_uploaded = FactoryGirl.create(:story, status: Story.statuses[:uploaded])
      story1 = FactoryGirl.create(:story, title: 'My school ' + SecureRandom.uuid, status: Story.statuses[:uploaded])
      story2 = FactoryGirl.create(:story, title: 'school ' + SecureRandom.uuid, status: Story.statuses[:uploaded])
      story_draft = FactoryGirl.create(:story)
      
      Story.reindex

      get :index
      
      expect(assigns(:stories).collect(&:title).include?(story1.title)).to be true
      expect(assigns(:stories).collect(&:title).include?(story2.title)).to be true
    end

    it "assigns @upload_running as true when upload is already running" do
      FactoryGirl.create(:story, status: Story.statuses[:uploaded])
      FactoryGirl.create(:story, status: Story.statuses[:draft])
      allow(Delayed::Job).to receive(:select) { [Delayed::Job.new] }

      get :index

      expect(assigns(:upload_running)).to be true
    end

    it "assigns @upload_running as false when upload is not running" do
      FactoryGirl.create(:story, status: Story.statuses[:uploaded])
      FactoryGirl.create(:story, status: Story.statuses[:draft])
      allow(Delayed::Job).to receive(:select) { [] }

      get :index

      expect(assigns(:upload_running)).to be false
    end
    it "should search by story_title" do
      story1 = FactoryGirl.create(:story, title: 'School ' + SecureRandom.uuid, status: Story.statuses[:uploaded])
      story2 = FactoryGirl.create(:story, title: 'College ' + SecureRandom.uuid, status: Story.statuses[:uploaded])
      
      Story.reindex

      search_params = {query: "School"}
      get :index, search: search_params
      expect(assigns(:stories).collect(&:title).include?(story1.title)).to be true
      expect(assigns(:stories).collect(&:title).include?(story2.title)).to be false
    end
    it "should search by language" do
      language = FactoryGirl.create(:language, name: SecureRandom.uuid.gsub('-', ''))
      another_language = FactoryGirl.create(:language, name: SecureRandom.uuid.gsub('-', ''))
      story1 = FactoryGirl.create(:story, status: Story.statuses[:uploaded], language: language)
      story2 = FactoryGirl.create(:story, status: Story.statuses[:uploaded], language: another_language)
      Story.reindex

      search_params = {query: language.name}
      post :index, search: search_params

      expect(assigns(:stories).collect(&:title).include?(story1.title)).to be true
      expect(assigns(:stories).collect(&:title).include?(story2.title)).to be false
    end
    it "should search by author" do
      fav_author = FactoryGirl.create(:user, name: 'My Favorite Author')
      story1 = FactoryGirl.create(:story, status: Story.statuses[:uploaded], authors: [fav_author])
      story2 = FactoryGirl.create(:story, status: Story.statuses[:uploaded])
      Story.reindex

      search_params = {query: "Favorite"}
      post :index, search: search_params

      expect(assigns(:stories).collect(&:title).include?(story1.title)).to be true
      expect(assigns(:stories).collect(&:title).include?(story2.title)).to be false
    end
  end

  describe "POST upload" do
    it "should start upload when it is not already running" do
      uploader = double("uploader")
      allow(uploader).to receive(:upload) { true }
      allow(uploader).to receive(:check_input_file) { true}
      allow(StoryUpload::Uploader).to receive(:new) { uploader }
      allow(Delayed::Job).to receive(:select) { [] }

      post :upload

      expect(uploader.upload).to be true
      expect(response).to redirect_to(dashboard_path)
    end

    it "should not start upload when it is already running" do
      uploader = double("uploader")
      allow(StoryUpload::Uploader).to receive(:new) { uploader }
      allow(Delayed::Job).to receive(:select) { [Delayed::Job.new] }

      post :upload

      expect(uploader).not_to receive(:upload)
      expect(response).to redirect_to(dashboard_path)
    end

    it "should not start upload when csv not found" do
      uploader = double("uploader")
      allow(uploader).to receive(:check_input_file) { true }
      allow(Delayed::Job).to receive(:select) { [] }

      post :upload

      expect(flash[:error]).to eq "Unable to find csv file in the path"
    end
  end

  describe "POST set role" do

    it "should not save with blank email" do

       user = FactoryGirl.create(:user)

       attributes = {:user => { :user_email => '', :role => 'reviewer'}}
       post :set_role, attributes  

       expect(assigns(:user).present?).to eql(false)
     end

     it "should not save with blank role" do

       user = FactoryGirl.create(:user)

       attributes = {:user => { :user_email => 'user.email', :role => ''}}
       post :set_role, attributes  

       expect(assigns(:user).present?).to eql(false)
     end

     it "should not save with unknown user" do

       user = FactoryGirl.create(:user)

       attributes = {:user => { :user_email => 'user.email', :role => 'reviewer'}}
       post :set_role, attributes  

       expect(assigns(:user).present?).to eql(false)
     end

    #  it "should show all the users expect current user" do
    #   @content_manager= FactoryGirl.create(:content_manager, email: 'cm@gmail.com')
    #   sign_in @content_manager
    #   user2 = FactoryGirl.create(:user, email: 'user2@gmail.com')
    #   user3 = FactoryGirl.create(:user, email: 'user3@gmail.com')

    #   attributes = {:id => @content_manager.id}

    #   get :roles, attributes

    #   expect(assigns(:users).collect(&:email).include?(@content_manager.email)).to be false
    #   expect(assigns(:users).collect(&:email).include?(user2.email)).to be true
    #   expect(assigns(:users).collect(&:email).include?(user3.email)).to be true
    # end
  end

  describe "POST edit story category" do
    it "should update story category with provided value" do
      category = FactoryGirl.create(:story_category, :name => "Audio Book")
      attributes = {:category => { :name => "Audio Books"} , :id => category.id}
      post :edit_story_category , attributes
      expect(assigns(:category).name).to eql("Audio Books")
    end

    it "should not update story category if name is nil" do
      category = FactoryGirl.create(:story_category, :name => "Audio Book")
      attributes = {:category => { :name => ""} , :id => category.id}
      post :edit_story_category , attributes
      expect(assigns(:category).valid?).to eql(false)
    end

    it "should strip beginning and trailing white spaces before updating story category" do
      category = FactoryGirl.create(:story_category, :name => "Audio Book")
      attributes = {:category => { :name => "  Audio Books  "} , :id => category.id}
      post :edit_story_category , attributes
      expect(assigns(:category).name).to eql("Audio Books")
    end
  #ativate after code change
  #   it "should handle nil when editing story category" do
  #     category = FactoryGirl.create(:story_category, :name => "Audio Book")
  #     attributes = {:category => { :name => nil} , :id => category.id}
  #     post :edit_story_category , attributes
  #     expect(assigns(:category).valid?).to eql(false)
  #   end
  end

  describe "POST create story category" do
    it "should create a new category with provided value" do
      attributes = {:category => { :name => "Audio Books"}}
      post :create_story_category, attributes
      expect(assigns(:category).name).to eql("Audio Books")
    end

    it "should not allow duplicate category entry " do
      FactoryGirl.create(:story_category, :name => "Audio Book")
      attributes = {:category => { :name => "Audio Book"}}
      post :create_story_category , attributes
      expect(assigns(:category).valid?).to eql(false)
    end

    it "should strip white trailing spaces for a new category entry" do
      attributes = {:category => { :name => "  Audio Books  "}}
      post :create_story_category , attributes
      expect(assigns(:category).name).to eql("Audio Books")
    end

    it "should handle nil values" do
      attributes = {:category => { :name => nil}}
      post :create_story_category, attributes
      expect(assigns(:category).valid?).to eql(false)
    end
  end

  describe "POST edit illustration category" do
    it "should update illustration category with provided value" do
      category = FactoryGirl.create(:illustration_category, :name => "Audio Book")
      attributes = {:category => { :name => "Audio Books"} , :id => category.id}
      post :edit_illustration_category , attributes
      expect(assigns(:category).name).to eql("Audio Books")
    end
    #activate after code change
    # it "should not update illustration category if name is nil" do
    #   category = FactoryGirl.create(:illustration_category, :name => "Audio Book")
    #   attributes = {:category => { :name => ""} , :id => category.id}
    #   post :edit_illustration_category , attributes
    #   expect(assigns(:category).valid?).to eql(false)
    # end

    it "should strip beginning and trailing white spaces before updating illustration category" do
      category = FactoryGirl.create(:illustration_category, :name => "Audio Book")
      attributes = {:category => { :name => "  Audio Books  "} , :id => category.id}
      post :edit_illustration_category , attributes
      expect(assigns(:category).name).to eql("Audio Books")
    end
  #Activate after code change
  #   it "should handle nil when editing illustration category" do
  #     category = FactoryGirl.create(:illustration_category, :name => "Audio Book")
  #     attributes = {:category => { :name => nil} , :id => category.id}
  #     post :edit_illustration_category , attributes
  #     expect(assigns(:category).valid?).to eql(false)
  #   end
  end

  describe "POST create illustration category" do
    it "should create a new category with provided value" do
      attributes = {:category => { :name => "Audio Books"}}
      post :create_illustration_category, attributes
      expect(assigns(:category).name).to eql("Audio Books")
    end

    it "should not allow duplicate category entry " do
      FactoryGirl.create(:illustration_category, :name => "Audio Book")
      attributes = {:category => { :name => "Audio Book"}}
      post :create_illustration_category , attributes
      expect(assigns(:category).valid?).to eql(false)
    end

    it "should strip white trailing spaces for a new category entry" do
      attributes = {:category => { :name => "  Audio Books  "}}
      post :create_illustration_category , attributes
      expect(assigns(:category).name).to eql("Audio Books")
    end

    it "should handle nil values" do
      attributes = {:category => { :name => nil}}
      post :create_illustration_category, attributes
      expect(assigns(:category).valid?).to eql(false)
    end
  end

  describe "POST create language" do
    it "should update category with provide value" do
      FactoryGirl.create(:language_font, :font => "Noto Sans", :script => 'bengali')
      attributes = {:language => { :name => "Bengali", :script => 'bengali'}}
      post :create_language, attributes
      expect(assigns(:language).name).to eql("Bengali")
    end

    it "should not allow duplicate category entry " do
      FactoryGirl.create(:language_font, :font => "Noto Sans", :script => 'bengali')
      FactoryGirl.create(:language, :name => "Bengali")
      attributes = {:language => { :name => "Bengali", :script => 'bengali'}}
      post :create_language , attributes
      expect(assigns(:language).valid?).to eql(false)
    end

    it "should strip white trailing spaces for a new language entry" do
      FactoryGirl.create(:language_font, :font => "Noto Sans", :script => 'kannada')
      attributes = {:language => { :name => "  Kannada  ", :script => 'kannada'}}
      post :create_language, attributes
      expect(assigns(:language).name).to eql("Kannada")
    end

    it "should handle nil values" do
      FactoryGirl.create(:language_font, :font => "Noto Sans", :script => 'bengali')
      attributes = {:language => { :name => nil, :script => nil}}
      post :create_language, attributes
      expect(assigns(:language).valid?).to eql(false)
    end
  end

  describe "POST edit styles" do
    it "should update style with provided value" do
      style = FactoryGirl.create(:style, :name => "Black and ")
      attributes = {:style => { :name => "Black and white"} , :id => style.id}
      post :edit_style, attributes
      expect(assigns(:style).name).to eql("Black and white")
    end

    it "should not update style if name is blank" do
      style = FactoryGirl.create(:style, :name => "Black and white")
      attributes = {:style => { :name => ""} , :id => style.id}
      post :edit_style , attributes
      expect(assigns(:style).valid?).to eql(false)
    end

    it "should strip beginning and trailing white spaces before updating style" do
      category = FactoryGirl.create(:style, :name => "Black and white")
      attributes = {:style => { :name => "  Black and white  "} , :id => category.id}
      post :edit_style , attributes
      expect(assigns(:style).name).to eql("Black and white")
    end
    #Activate after code change
    # it "should handle nil when editing style" do
    #   category = FactoryGirl.create(:style, :name => "Black and white")
    #   attributes = {:style => { :name => nil} , :id => category.id}
    #   post :edit_style, attributes
    #   expect(assigns(:style).valid?).to eql(false)
    # end
  end

  describe "POST create donor" do
    it "should create a new donor" do

      attributes = {:donor => {:name => "test donor", :logo => Rack::Test::UploadedFile.new('spec/photos/logo.png', 'image/png')}}
      post :create_donor, attributes

      expect(assigns(:donor).name).to eql("test donor")
      expect(assigns(:donor).logo.present?).to eql(true)
    end 

    it "should not create a new donor with empty donor name" do

      attributes = {:donor => {:name => nil, :logo => Rack::Test::UploadedFile.new('spec/photos/logo.png', 'image/png')}}
      post :create_donor, attributes

      expect(assigns(:donor).valid?).to eql(false)
    end

    it "should not create a new donor with empty donor name" do

      attributes = {:donor => {:name => "test", :logo => nil}}
      post :create_donor, attributes

      expect(assigns(:donor).valid?).to eql(false)
    end
  end

  describe "POST create style" do
    it "should create a new style with provided value" do
      attributes = {:style => {:name => "Black and white"}}
      post :create_style, attributes
      expect(assigns(:style).name).to eql("Black and white")
    end

    it "should not allow duplicate category entry " do
      FactoryGirl.create(:style, :name => "Black and white")
      attributes = {:style => { :name => "Black and white"}}
      post :create_style , attributes
      expect(assigns(:style).valid?).to eql(false)
    end

    it "should strip white trailing spaces for a new style entry" do
      attributes = {:style => { :name => " Folk art  "}}
      post :create_style, attributes
      expect(assigns(:style).name).to eql("Folk art")
    end

    it "should handle nil values" do
      attributes = {:style => { :name => nil}}
      post :create_style, attributes
      expect(assigns(:style).valid?).to eql(false)
    end
  end

  describe "Post pulled down stories" do
    it "should save a pulled down story" do

       @story = FactoryGirl.create(:story)
       attributes = {:id => @story.id, :reasons => "Sample pulled down", :pulled_down => {:pulled_down => @story, :reasons => "sample pulled down" }} 

       post :pull_down_story, attributes

       @story.reload

       expect((@story).pulled_downs.present?).to eql(true)
    end
  end

  describe "Post pulled down illustration" do
    it "should save a pulled down illustration" do

      user = FactoryGirl.create(:user)
      person = FactoryGirl.create(:person, :user => user)
       @illustration = FactoryGirl.create(:illustration, :illustrators => [person])
       
       attributes = {:id => @illustration.id, :reasons => "Sample pulled down", :pulled_down => {:pulled_down => @illustration, :reasons => "sample pulled down" }} 
    
       post :pull_down_illustration, attributes

       @illustration.reload

       expect((@illustration).pulled_downs.present?).to eql(true)
    end
  end

  describe "clear story flag" do
    it "should clear story flag" do

      @user = FactoryGirl.create(:user)
      @story = FactoryGirl.create(:story, status: Story.statuses[:published])
      attributes = {:id => @story.id}
      @user.flag(@story, "sample reason")

      get :clear_story_flag, attributes

      expect((@story).flagged?).to eql(false)
    end
  end

  describe "clear illustration flag" do
    it "should clear illustration flag" do

      @user = FactoryGirl.create(:user)
      @illustration = FactoryGirl.create(:illustration, flaggings_count: '1')
      attributes = {:id => @illustration.id}
      @user.flag(@illustration, "sample reason")

      get :clear_illustration_flag , attributes

      expect((@illustration).flagged?).to eql(false)
    end
  end

  describe "activate_story flag" do
    it "should activate_story flag" do

      @user = FactoryGirl.create(:user)
      @story = FactoryGirl.create(:story)
      attributes = {:id => @story.id}
      @user.flag(@story, "sample reason")

      get :activate_story, attributes

      expect((@story).flagged?).to eql(false)
      expect((@story).pulled_downs.present?).to eql(false)
      expect((@story).status).to eql("published")
    end
  end

   describe "activate_illustration flag" do
    it "should activate_illustration flag" do

      @user = FactoryGirl.create(:user)
      @illustration = FactoryGirl.create(:illustration)
      @user.flag(@illustration, "sample reason")

      attributes = {:id => @illustration.id}
  
      get :activate_illustration, attributes

      expect((@illustration).flagged?).to eql(false)
      expect((@illustration).pulled_downs.present?).to eql(false)
    end
  end


  describe "Authorisation" do
    before(:each) do
      sign_out @content_manager
    end

    it "should not authorise anyone else but content manager for all action" do
      get :index
      expect(response).to redirect_to(new_user_session_path)

      users = [
        FactoryGirl.create(:user),
        FactoryGirl.create(:reviewer),
        FactoryGirl.create(:admin),
        FactoryGirl.create(:reviewer),
      ]
      actions = [:index, :upload, :roles, :story_categories, :illustration_categories, :languages, :styles]
      users.each do |user|
        actions.each do |action|
          sign_in user

          get action

          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
