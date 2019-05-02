# encoding: utf-8
require 'rails_helper'

describe StoriesController, :type => :controller do

  describe "GET new" do
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user
    end

    it "renders the new template" do
      get :new
      # We are not rendering html anymore. html call redirects to /start
      expect(response).to redirect_to("/start")
    end

  end

  describe "User Authentication" do
    it "GET new - redirects to sign_in page when user is not signed in" do
      get :new

      expect(response).to redirect_to(new_user_session_path)
    end

     it "POST create - redirects to sign_in page when user is not signed in" do
      post :create, story: {}

      expect(response).to redirect_to(new_user_session_path)
    end
 end

  describe "Story download count reset" do
    it "POST - should reset the story download count for user" do
      @user = FactoryGirl.create(:user, :story_download_count => 40)
      post :reset_story_download_count, :email => @user.email
      user = User.find_by_email(@user.email)
      expect(response.status).to eql(200)
      expect(user.story_download_count).to eql 0
    end
  end

  describe "POST create" do
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user
      FactoryGirl.create(:front_cover_page_template,default: true,orientation: 'landscape')
      FactoryGirl.create(:story_page_template,default: true,orientation: 'landscape')
      FactoryGirl.create(:back_inner_cover_page_template,default: true,orientation: 'landscape')
      FactoryGirl.create(:back_cover_page_template,default: true,orientation: 'landscape')
    end
=begin
    it "should redirect to index with a notice on successful save" do
      language = FactoryGirl.create(:english)
      mountain = FactoryGirl.create(:story_category)
      nature = FactoryGirl.create(:story_category)
      attributes = FactoryGirl.attributes_for(:draft_story)
      organization = FactoryGirl.create(:organization)
      attributes.merge!({
        english_title: nil,
        language_id: language.id,
        reading_level: '1',
        orientation: 'landscape'
      })

      post :create, story: attributes

      expect(assigns(:story).authors).to match_array([@user])
      expect(assigns(:story).language).to eql(language)
      expect(assigns(:story).reading_level).to eql('1')
      expect(assigns(:story).orientation).to eql("landscape")
      expect(assigns(:story).has_front_cover_page?).to eql(true)
      expect(assigns(:story).has_story_page?).to eql(true)
      expect(assigns(:story).has_back_inner_cover_page?).to eql(true)
      expect(assigns(:story).has_back_cover_page?).to eql(true)
      expect(response).to redirect_to(story_editor_path(assigns(:story)))
    end
=end
  end

  describe "DELETE delete" do
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user
    end
    before :each do
      @story_uploaded = FactoryGirl.create(:story,status: Story.statuses[:uploaded])
      @story_review = FactoryGirl.create(:story,status: Story.statuses[:draft])
    end

    it "remove story with uploaded status as content_manager" do
      @content_manager = FactoryGirl.create(:content_manager)
      @content_manager.site_roles = "content_manager"
      @content_manager.save!
      sign_in @content_manager
       expect{
             delete :destroy, id: @story_uploaded.id
           }.to change(Story,:count).by(-1)
    end

    it "should not delete story in another status" do
       expect{
             delete :destroy, id: @story_review.id
           }.to change(Story,:count).by(0)
    end
  end
  describe "process_publish" do
    before :each do
      @content_manager= FactoryGirl.create(:content_manager)
      FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
      @story_uploaded = FactoryGirl.create(:story,status: Story.statuses[:uploaded])
      Delayed::Job.destroy_all
    end

    it "should change story status to publish_pending" do
      @story_uploaded.process_publish

      @story_uploaded.reload
      expect(@story_uploaded.publish_pending?).to be true
    end

    it "should add publish story job to queue" do
      @story_uploaded.process_publish

      expect(Delayed::Job.all.select{|j| j.queue == 'story_publish'}.count).to be 1
    end
  end

  describe "PATCH publish" do
    before :each do
      @user = FactoryGirl.create(:content_manager)
      @user.site_roles = "content_manager"
      @user.save!
      sign_in @user
    end
    before :each do
      FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
      @story_uploaded = FactoryGirl.create(:story,status: Story.statuses[:uploaded])
    end

    it "should change story status to publish_pending" do
      patch :publish, id: @story_uploaded.id

      @story_uploaded.reload
      expect(@story_uploaded.publish_pending?).to be true
    end

    it "should add publish story job to queue" do
      patch :publish, id: @story_uploaded.id

      expect(Delayed::Job.all.select{|j| j.queue == 'story_publish'}.count).to be 1
    end
  end

  describe "GET versions" do
    it "should navigate to matching story detail page when only one story is present for the selected language and level combination" do
      original_story = FactoryGirl.create(:story, 'reading_level' => '4')
      relevelled_story = original_story.new_derivation(FactoryGirl.attributes_for(:story, 'reading_level' => '1').slice!(:id), original_story.authors.first,original_story.authors.first, "relevelled")
      relevelled_story.save

      get :versions, {id: original_story.id, language: "#{original_story.language.id}", reading_level: "#{relevelled_story.reading_level}"}

      expect(response).to redirect_to(react_stories_show_path(relevelled_story.to_param))
    end

    it "should include only descendants when selecting other versions" do
      english = FactoryGirl.create(:english)
      kannada = FactoryGirl.create(:kannada)
      original_story = FactoryGirl.create(:story, language: english)
      kannada_story = original_story.new_derivation(
        FactoryGirl.attributes_for(:story, language_id: kannada.id).slice!(:id),
        original_story.authors.first,
        original_story.authors.first,
        "translated")
      kannada_story.save!
      english_story = kannada_story.new_derivation(
        FactoryGirl.attributes_for(:story, language_id: english.id).slice!(:id),
        original_story.authors.first,
        original_story.authors.first,
        "translated")
      english_story.save!

      get :versions, {id: kannada_story.id, language: "#{english.id}", reading_level: "#{kannada_story.reading_level}"}

      expect(response).to redirect_to(react_stories_show_path(english_story.to_param))
    end

    it "should include translations as versions" do
      english = FactoryGirl.create(:english)
      kannada = FactoryGirl.create(:kannada)
      original_story = FactoryGirl.create(:story, language: english)
      translated_story = original_story.new_derivation(
        FactoryGirl.attributes_for(:story, language_id: kannada.id).slice!(:id), 
        original_story.authors.first, 
        original_story.authors.first,
        "translated")
      translated_story.save!

      get :versions, {id: original_story.id, language: "#{kannada.id}", reading_level: "#{original_story.reading_level}"}

      expect(response).to redirect_to(react_stories_show_path(translated_story.to_param))
    end

    it "should render versions view when more than one story is present for the selected language and level combination" do
      original_story = FactoryGirl.create(:story, 'reading_level' => '4')
      relevelled_story = original_story.new_derivation(FactoryGirl.attributes_for(:story, 'reading_level' => '1').slice!(:id), original_story.authors.first,original_story.authors.first, "relevelled")
      relevelled_story.save
      another_relevelled_story = original_story.new_derivation(FactoryGirl.attributes_for(:story, 'reading_level' => '1').slice!(:id), original_story.authors.first,original_story.authors.first, "relevelled")
      another_relevelled_story.save

      get :versions, {id: original_story.id, language: "#{original_story.language.id}", reading_level: "#{relevelled_story.reading_level}"}

      expect(assigns(:versions)).to match_array([relevelled_story, another_relevelled_story])
      expect(response).to render_template(:versions)
    end
  end

  describe "POST create story from illustration" do 
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user
      FactoryGirl.create(:front_cover_page_template,default: true,orientation: 'landscape')
      FactoryGirl.create(:story_page_template,default: true,orientation: 'landscape', name: "sp_h_iT75_cB25")
      FactoryGirl.create(:back_inner_cover_page_template,default: true,orientation: 'landscape')
      FactoryGirl.create(:back_cover_page_template,default: true,orientation: 'landscape')
    end
  end

  describe "GET flagging a story" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @story = FactoryGirl.create(:story)
      sign_in @user
    end

    it "should force the user to sign in before flagging a story" do
      sign_out @user
      attributes = {id: @story.id, reasons: 'reason for flagging'}

      xhr :post, :flag_story, attributes

      expect(response.status).to eql(401)
    end

    it "should allow the user to flag a story" do
      attributes = {id: @story.id, reasons: 'reason for flagging'}

      xhr :post, :flag_story, attributes

      @story.reload
      expect(response).to render_template("flag_story")
      expect(@user.flagged?(@story, 'reason for flagging')).to be true
    end

    it "should not do anything when the user flags the same story more than once" do
      attributes = {id: @story.id, reasons: 'reason for flagging'}

      xhr :post, :flag_story, attributes
      xhr :post, :flag_story, attributes

      @story.reload
      expect(response).to render_template("new_flag_story")
      expect(@user.flagged?(@story, 'reason for flagging')).to be true
    end
  end

  describe '#story_review_new' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @cm = FactoryGirl.create(:content_manager)
      @story = FactoryGirl.create(:story)
      User.reindex
      Story.reindex
      allow_any_instance_of(Story).to receive(:flagged?).and_return(false)
      @params = {flag: 'true', id: @story.id}
    end

    it "Should return flash message and redirect to root path if the story is already flagged" do
      flagged = "This story has been flagged"
      sign_in @user
      allow_any_instance_of(Story).to receive(:flagged?).and_return(true)
      get :story_review_new, @params
      expect(response.status).to eq 302
      expect(flash["error"]).to eq flagged
    end

    it "Should render story_review_new if the flag param is false" do
      sign_in @cm
      FactoryGirl.create(:english)
      params = {flag: 'false', id: @story.id}
      get :story_review_new, params
      expect(response.status).to eq 200
      expect(flash["error"]).to eq nil
    end

    it "Should redirect to root path if the user is not authorised to do so" do
      not_authorised = "You are not authorised to do this."
      sign_in @user
      Story.reindex
      get :story_review_new, @params
      expect(response.status).to eq 302
      expect(flash["error"]).to eq not_authorised
    end

    it "Should redirect to root path is the story already has reviewer comment" do
      flagged = "Story has been already reviewed."
      sign_in @cm
      ReviewerComment.new(story: @story, user: @user, rating: 5).save!
      Story.reindex
      get :story_review_new, @params
      expect(response.status).to eq 302
      expect(flash["error"]).to eq flagged
    end

    it "Should render story_review_new if the story is not flagged and flag param is true" do
      sign_in @cm
      get :story_review_new, @params
      expect(response.status).to eq 200
      expect(flash["error"]).to be nil
    end

  end

  describe '#reviewer_comments' do
    before(:each) do
      @cm = FactoryGirl.create(:content_manager)
      @en_lang = FactoryGirl.create(:english)
      @story = FactoryGirl.create(:story, language: @en_lang)
      @params = {"reviewer_comment" => { "rating" => 3,
                                          "comments"=> {"Others"=>"",
                                                        "other_comments"=>"test",
                                                        "Story is wrongly categorised"=>["", "The language tag is incorrect. The story is in Bhojpuri language"]
                                                        }
                                        },
                  "language"=> @story.language.name,
                  "reading_level"=> @story.reading_level,
                  "id" => @story.id
                }
    end

    it 'Should add comments to the story' do
      sign_in @cm
      params = @params.dup
      params['reviewer_comment']['comments']= {"Others"=>"","other_comments"=>"test"}
      post :reviewer_comments, params
      flash_message = "Thank you for rating this story"
      expected_output = { "Others"=>["test"]}
      comments = JSON.parse(@story.reviewer_comment.comments)
      expect(comments["Others"]).to eq expected_output["Others"]
      expect(flash[:notice]).to eq flash_message
    end

    it "Should add comments and flag the story respectively" do
      sign_in @cm
      post :reviewer_comments, @params
      flash_message = "The story has been flagged. Thank you for drawing our attention to this story."
      expected_output = {"Others"=>["test"], 
                        "Story is wrongly categorised"=>["The language tag is incorrect. The story is in Bhojpuri language"] }
      comments = JSON.parse(@story.reviewer_comment.comments)
      expect(comments["Others"]).to eq expected_output["Others"]
      expect(comments["Story is wrongly categorised"]).to eq expected_output["Story is wrongly categorised"]
      expect(flash[:error]).to eq flash_message
    end
    
    it "Should not add comments if the user is not signed in" do
      flash_message = "You need to sign in or sign up before continuing."
      post :reviewer_comments, @params
      expect(response.status).to eq 302
      expect(flash['alert']).to eq flash_message
    end
    
    it "Should return error message when review rating is not passed" do
      params = @params.dup
      params['reviewer_comment']['rating'] = nil
      sign_in @cm
      post :reviewer_comments, params
      flash_message = 'Unable to save reviewer comment'
      expect(flash['error']).to eq flash_message
    end
  end

end
