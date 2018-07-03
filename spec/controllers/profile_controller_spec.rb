require 'rails_helper'

RSpec.describe ProfileController, :type => :controller do

  describe "GET index" do
    before :each do
      @admin= FactoryGirl.create(:admin)
      sign_in @admin
    end

    it "returns http success" do
      get :index
      expect(response).to be_success
    end
  end

 

  describe "User published stories" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    it "should allow user to view his published stories" do
      story1 = FactoryGirl.create(:story, authors: [@user], status: Story.statuses[:published])
      story2 = FactoryGirl.create(:story, authors: [@user], status: Story.statuses[:published])
      user1 = FactoryGirl.create(:user)
      story3 = FactoryGirl.create(:story, authors: [user1], status: Story.statuses[:published])

      get :stories

      expect(assigns(:stories)).to match_array([story1, story2])
    end
  end

  describe "Publisher published stories" do
    before(:each) do
      @publisher = FactoryGirl.create(:publisher)
      sign_in @publisher
    end
    it "should allow publisher to view his published stories" do
      story1 = FactoryGirl.create(:story, publisher: @publisher, authors: [@publisher], status: Story.statuses[:published])
      story2 = FactoryGirl.create(:story, publisher: @publisher, authors: [@publisher], status: Story.statuses[:published])
      publisher = FactoryGirl.create(:publisher)
      story3 = FactoryGirl.create(:story, publisher: publisher, authors: [publisher], status: Story.statuses[:published])

      get :stories

      expect(assigns(:stories)).to match_array([story1, story2])
    end
  end

  describe "User published stories under edit" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    it "should allow user to view his published stories under edit" do
      story1 = FactoryGirl.create(:story, authors: [@user], status: Story.statuses[:edit_in_progress])
      story2 = FactoryGirl.create(:story, authors: [@user], status: Story.statuses[:edit_in_progress])
      user1 = FactoryGirl.create(:user)
      story3 = FactoryGirl.create(:story, authors: [user1], status: Story.statuses[:edit_in_progress])

      get :edit_in_progress

      expect(assigns(:edit_in_progress_stories)).to match_array([story1, story2])
    end
  end

  describe "User de activated stories" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    it "should allow user to view his deacivated stories" do
      story1 = FactoryGirl.create(:story, authors: [@user], status: Story.statuses[:de_activated])
      story2 = FactoryGirl.create(:story, authors: [@user], status: Story.statuses[:de_activated])
      FactoryGirl.create(:story, authors: [@user])

      get :deactivated_stories

      expect(assigns(:deactivated_stories)).to match_array([story1, story2])
    end
  end

  describe "User Drafts" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "should allow user to view his drafts" do
      draft1 = FactoryGirl.create(:story, authors: [@user], status: Story.statuses[:draft], dummy_draft: false)
      draft2 = FactoryGirl.create(:story, authors: [@user], status: Story.statuses[:draft], dummy_draft: false)
      FactoryGirl.create(:story, authors: [@user])
      FactoryGirl.create(:story, authors: [FactoryGirl.create(:user)], status: Story.statuses[:draft])

      get :drafts

      expect(assigns(:drafts)).to match_array([draft1, draft2])
    end
  end

  describe "DELETE draft story" do
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user
    end
    before :each do
      @story_draft = FactoryGirl.create(:story, authors: [@user], status: Story.statuses[:draft])
      @child_story = FactoryGirl.create(:story, authors: [@user], ancestry: @story_draft.id, status: Story.statuses[:draft])
      @story_uploaded = FactoryGirl.create(:story, authors: [@user], status: Story.statuses[:uploaded])
    end

    it "Should not remove story which has chaild stories" do
      expect{
        delete :delete_draft, id: @story_draft.id
      }.to change(Story,:count).by(0)
    end

    it "remove story with draft status" do
      expect{
        delete :delete_draft, id: @child_story.id
      }.to change(Story,:count).by(-1)
    end

    it "should not delete story in another status" do
      expect{
        delete :delete_draft, id: @story_uploaded.id
      }.to change(Story,:count).by(0)
    end
  end

  describe "User Change password" do
    before(:each) do
      @user = FactoryGirl.create(:user, email: "user1@sample.com", password: "password")
      sign_in @user
    end

    it "should render the change password form" do
      xhr :get, :edit_password
      expect(response).to render_template("edit_password")
    end

    it "should update the password with new password params" do
      attributes = {:user => {current_password: "password", password: "newpassword", password_confirmation: "newpassword"}}
      
      xhr :post, :update_password, attributes

      expect(assigns(:user).valid_password?("newpassword")).to be true
      #expect(response).to render_template("update_password") commented becouse it is now redirection to user sign in page
    end 

    it "should not update the password with if the old password and new password are same " do
      attributes = {:user => {current_password: "password", password: "password", password_confirmation: "password"}}
      
      xhr :post, :update_password, attributes

      expect(response).to render_template("edit_password")
    end
  end
end
