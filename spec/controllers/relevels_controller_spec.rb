require 'rails_helper'

describe RelevelsController, :type => :controller do

  describe "GET story translate new" do
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user
      @story = FactoryGirl.create(:story)
    end

    it "renders the relevel template" do
      xhr :get, :new, story_id: @story.id, format: :js
      expect(response).to render_template(:new)
    end
  end

  describe "POST create story relevel" do
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user
      language = FactoryGirl.create(:english)
      mountain = FactoryGirl.create(:story_category)
      nature = FactoryGirl.create(:story_category)
      attributes = FactoryGirl.attributes_for(:story)
      attributes.merge!({
        title: 'my story',
        synopsis: 'my story synopsis',
        english_title: 'my story', 
        language_id: language.id, 
        reading_level: '1',
        derivation_type: 'relevelled',
        category_ids: [mountain.id, nature.id]
      })
      @story = FactoryGirl.create(:story, attributes)
    end

    it "Should relevel the story" do
      allow_any_instance_of(Story).to receive(:valid?).and_return true
      get :relevel_story, {story_id: @story.id}
      expect(assigns(:relevelled_story).class).to eq Story
    end

    it "Should not relevel the story if invalid" do
      allow_any_instance_of(Story).to receive(:valid?).and_return false
      request.env["HTTP_REFERER"] = "where_i_came_from"
      get :relevel_story, {story_id: @story.id}
      expect(response.status).to eq 302
      response.should redirect_to "where_i_came_from"
    end
  end

  context '#update' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @story = FactoryGirl.create(:story)
      @rl_story = FactoryGirl.create(:story, dummy_draft: true)
      sign_in @user
    end

    it "Should update the story only if it is valid" do
      xhr :post, :update, {id: @story.id, story_id: @rl_story.id, story: {reading_level: '1'}}
      @story.reload
      expect(response.status).to eq 200
      @rl_story.reload
      expect(@rl_story.reading_level).to eq "1"
      expect(response).to render_template("update")
    end

    it "Should not update the invalid story" do
      allow_any_instance_of(Story).to receive(:valid?).and_return(false)
      xhr :post, :update, {id: @story.id, story_id: @rl_story.id, story: {reading_level: '1'}}
      @story.reload
      expect(response.status).to eq 200
      expect(response).to render_template("new")
    end
  end

end
