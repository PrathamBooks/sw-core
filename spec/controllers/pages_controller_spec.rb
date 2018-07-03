require 'rails_helper'

describe PagesController, :type => :controller do

  describe "GET new" do
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user
      @story = FactoryGirl.create(:story)
    end

    it "returns http success" do
      get :new , story_id: @story.id

      expect(response).to be_success
    end

    it "load page template as @templates" do
      template1 = FactoryGirl.create(:story_page_template)
      template2 = FactoryGirl.create(:story_page_template)

      get :new , story_id: @story.id
      expect(assigns(:story_page_templates)).to match_array([template1, template2])
    end

    it "load new page object as @page" do
      get :new , story_id: @story.id

      expect(assigns(:page).new_record?).to eql(true)
    end
  end


  describe "GET show" do
    it "should return page based on the id" do
      story = FactoryGirl.create(:story)
      story_page = FactoryGirl.create(:story_page, story: story)
      @user= FactoryGirl.create(:user)
      sign_in @user
      xhr :get, :show, id: story_page.id, story_id: story.id, format: :js

      expect(response).to render_template("show")
      expect(assigns(:page)).to eql(story_page)
    end
  end

  describe "GET navigate_to" do
    it "should return page based on the id" do
      story = FactoryGirl.create(:story)
      page = FactoryGirl.create(:story_page, story: story)

      xhr :get, :navigate_to, id: page.id, story_id: story.id, format: :js

      expect(response).to render_template("navigate_to")
      expect(assigns(:page)).to eql(page)
    end

    describe "POST create" do
      before :each do
        @user= FactoryGirl.create(:user)
        sign_in @user
        @story = FactoryGirl.create(:story)
      end

      it "should redirect to index with a notice on successful save" do
        page_template = FactoryGirl.create(:story_page_template)
        illustration = FactoryGirl.create(:illustration)
        attributes = FactoryGirl.attributes_for(:story_page)
        attributes.merge!({
          page_template_id: page_template.id,
          illustration_id: illustration.id,
          content: 'Content 1',
          story_id: @story.id
        })
        @story.build_book
        post :create, story_id: @story.id, story_page: attributes

        expect(response).to redirect_to(story_pages_path(@story))
        expect(assigns(:page).page_template).to eql(page_template)
        expect(assigns(:page).illustration_crop.illustration).to eql(illustration)
        expect(assigns(:page).story).to eql(@story)
        expect(assigns(:page).content).to eql('Content 1')
      end

      it "should re-render new template on failed save" do
        post :create, story_id: @story.id, story_page: {content: 'Content 1'}
        expect(assigns(:page).valid?).to eql(false)
        expect(response).to render_template(:new)
      end
    end

    describe "User Authentication" do
      before :each do
        @story = FactoryGirl.create(:story)
      end

      it "GET new - redirects to sign_in page when user is not signed in" do
        get :new , story_id: @story.id

        expect(response).to redirect_to(new_user_session_path)
      end

      it "POST create - redirects to sign_in page when user is not signed in" do
        post :create, story_id: @story.id, story: {}

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

end
