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

    it "renders 404 when story is not found" do
      expect{get :translate,id: 'invalid id'}.to raise_error(ActionController::RoutingError)
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

  end

end
