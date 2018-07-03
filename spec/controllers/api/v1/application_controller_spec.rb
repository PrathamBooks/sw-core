require 'rails_helper'
require 'spec_helper'

describe Api::V1::ApplicationController, :type => :controller do

  render_views
  before(:each) do
    @user= FactoryGirl.create(:user)
    @list_category = FactoryGirl.create(:list_category)
  end

  let(:json) { JSON.parse(response.body) }
  #set-locale for controller method
  context "POST should set local language" do
    it "should set language Hindi" do
      locale = {:locale => 'hi'}
      post :set_locale, locale, format: :json
      expect(ok: true)
      expect_status(200)
    end

    it "should set language English" do
      locale = {:locale => 'en'}
      post :set_locale, locale, format: :json
      expect(ok: true)
      expect_status(200)
    end
      # it "should give error - when given wrong query" do  # code change required SW-2731
      #     locale = {:locale => 'ei'}
      #     post :set_locale, locale, format: :json
      #     expect_status(400)
      #     expect(ok: false)
      #     expect(JSON.parse(response.body)['data'].key).to contain_exactly('errorCode', 'errorMessage')
      #     expect_json('data.errorCode', 400)
      #     expect_json('data.errorMessage', 'locale paramter missing')
      # end
      # it "should give error - when no query given" do
      #     locale = {:locale => ''}
      #     post :set_locale, locale, format: :json
      #     expect_status(400)
      #     expect(ok: false)
      #     expect(JSON.parse(response.body)['data'].key).to contain_exactly('errorCode', 'errorMessage')
      #     expect_json('data.errorCode', 400)
      #     expect_json('data.errorMessage', 'locale paramter missing')
      # end
  end
  context "POST open popup" do
    it "open popup - without login" do
      post :open_popup, format: :json
      expect_status(400)
      expect(ok: false)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('errorCode', 'errorMessage')
      expect_json('data.errorCode', 400)
      expect_json('data.errorMessage', 'Unable to find current_user')
    end
    it "open popup - with login" do
      sign_in @user
      expect(@user.phonestories_popup).to eq(nil)
      post :open_popup, format: :json
      expect_status(200)
      expect(ok: true)
      expect(@user.reload.phonestories_popup.popup_opened).to eq(true)
    end
  end
end
