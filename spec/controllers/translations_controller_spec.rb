require 'rails_helper'

describe TranslationsController, :type => :controller do

  describe "GET story translate new" do
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user
      @story = FactoryGirl.create(:story)
    end

    it "renders 404 when story is not found" do
      expect{get :translate,id: 'invalid id'}.to raise_error(ActionController::RoutingError)
    end
  end

  describe "POST create story translation" do
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user

      language = FactoryGirl.create(:english)
      attributes = FactoryGirl.attributes_for(:story)
      attributes.merge!({
        language_id: language.id
      })

      @story = FactoryGirl.create(:story, attributes)
      @page = FactoryGirl.create(:story_page, story: @story)

    end

    it "should redirect to index with a notice on successful save" do

      language = FactoryGirl.create(:kannada)

      tr_story_attributes = @story.dup.attributes.slice!('ancestry').merge!({
        story_id: @story.id,
        language_id: language.id
      })

      xhr :post, :create, story_id: @story.id, story: tr_story_attributes, format: :js

      expect(response).to render_template(:create)
    end
  end

end
