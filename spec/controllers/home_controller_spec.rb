require 'rails_helper'

describe HomeController, :type => :controller do
  describe "GET index" do
    it "should set statistics" do
      FactoryGirl.create(:story, status: Story.statuses[:published], reads: 5)
      FactoryGirl.create(:language)

      get :index

      expect(response).to render_template(:index)
      expect(assigns(:number_of_stories)).to be >= 0
      expect(assigns(:number_of_reads)).to be >= 0
      expect(assigns(:number_of_languages)).to be >= 0
    end

    it "should not count stories with bilingual languages" do
      lang1=FactoryGirl.create(:language, name: 'English', id: 1)
      lang2=FactoryGirl.create(:language, name: 'Hindi', id: 2)
      lang3=FactoryGirl.create(:language, name: 'English-Hindi', id: 3)
      lang4=FactoryGirl.create(:language, name: 'Telugu', id: 4)

      FactoryGirl.create(:story, status: Story.statuses[:published], language_id: lang1.id)
      FactoryGirl.create(:story, status: Story.statuses[:published], language_id: lang3.id)
      FactoryGirl.create(:story, status: Story.statuses[:published], language_id: lang2.id)
      FactoryGirl.create(:story, status: Story.statuses[:published], language_id: lang4.id)
      FactoryGirl.create(:story, status: Story.statuses[:published], language_id: lang3.id)

      get :index
      
      expect(response).to render_template(:index)
      expect(assigns(:number_of_languages)).to be == 3
    end
  end
end
