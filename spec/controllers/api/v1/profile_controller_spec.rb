require 'spec_helper'

RSpec.describe Api::V1::ProfileController, :type => :controller do

  render_views
  before(:each) do
    @user= FactoryGirl.create(:user)
  end
  let(:json) { JSON.parse(response.body) }

context "GET user details" do
    it "should show user details" do
      sign_in @user
      get :user_details, :id => @user.id, format: :json
      expect_json_keys('data', [:slug, :name, :description, :email, :website, :profileImage, :id, :books, :translations, :lists, :illustrations, :mediaMentions, :organization])
      ['books', 'translations', 'lists', 'illustrations', 'mediaMentions'].each do |data|
        expect_json_keys("data.#{data}", [:meta, :results])
      end
      ['books', 'translations', 'lists', 'illustrations', 'mediaMentions'].each do |data|
        expect_json_keys("data.#{data}.meta", [:hits, :perPage, :page, :totalPages])
      end
      expect_json(ok: true)
      expect_status(200)
    end
  end

  context "GET organisations details" do
  	it "should show organisations details" do
      org1 = FactoryGirl.create(:organization, id: 1)
      story_create = FactoryGirl.create(:story, status: Story.statuses[:published])
      get :org_details, id: org1.id, format: :json
      expect_json(ok: true)
      expect_json_keys('data', [:type, :name, :id, :description, :email, :website, :profileImage, :slug, :reading_lists, :mediaMentions, :socialMediaLinks])
      ['reading_lists', 'mediaMentions'].each do |data|
        expect_json_keys("data.#{data}", [:meta, :results])
      end
      ['reading_lists', 'mediaMentions'].each do |data|
        expect_json_keys("data.#{data}.meta", [:hits, :perPage, :page, :totalPages])
      end
      expect_json_keys('data.socialMediaLinks', [:facebookUrl, :rssUrl, :twitterUrl, :youtubeUrl])
      expect(response).to be_success
      expect_status(200)
    end
  end

  context "PUT popup-seen" do
    it "should set_popup_seen - with/without login" do
      sign_in @user
      put :set_popup_seen, format: :json
      expect_status(200)
      expect_json(ok: true)
      sign_out @user
      put :set_popup_seen, format: :json
      expect_status(400)
      expect_json(ok: false)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('errorCode', 'errorMessage')
      expect_json('data.errorCode', 400)
      expect_json('data.errorMessage', 'Unable to find user')
    end
  end

  context "PUT set_offline_book_popup_seen" do
    it "should set_offline_book_popup_seen - with/without login" do
      sign_in @user
      put :set_offline_book_popup_seen, format: :json
      expect_status(200)
      expect_json(ok: true)
      sign_out @user
      put :set_offline_book_popup_seen, format: :json
      expect_status(401)
    end
  end
end
