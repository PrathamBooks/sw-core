require "spec_helper"

  before(:each) do
    @user= FactoryGirl.create(:user)
    @list_category = FactoryGirl.create(:list_category)
  end
describe "Api::V1::Lists::Requests", :type => :request do
  context "SHOW/GET List with filters" do
    it "should show the list with filters" do
      cat = FactoryGirl.create(:list_category, :name => 'category_1', :translated_name => "Translated category_1")
      get '/api/v1/lists/filters',:id => 1,  format: :json
      expect_status(200)
      expect_json(ok: true)
      expect(JSON.parse(response.body).keys).to contain_exactly("ok", "data")
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("filters", "sortOptions")
      expect(JSON.parse(response.body)['data']['filters'][0].keys).to contain_exactly("name", "queryKey", "queryValues")
      expect(JSON.parse(response.body)['data']['filters'][0]['queryValues'][0].keys).to contain_exactly("name", "queryValue")
      expect(JSON.parse(response.body)['data']['sortOptions'][0].keys).to contain_exactly("name", "queryValue")
      expect_json('data.filters.0.name','Category')
      expect_json('data.filters.0.queryKey','category')
      expect_json('data.filters.0.queryValues.0.name', 'Translated category_1')
      expect_json('data.filters.0.queryValues.0.queryValue','category_1')
      expect_json('data.sortOptions.0.name','Most Liked')
      expect_json('data.sortOptions.1.name','Most Viewed')
      expect_json('data.sortOptions.2.name','New Arrivals')
      expect_json('data.sortOptions.0.queryValue','likes')
      expect_json('data.sortOptions.1.queryValue','views')
      expect_json('data.sortOptions.2.queryValue','published_at')
    end
  end
end
