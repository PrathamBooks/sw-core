require "spec_helper"

describe "Api::V0::AnalyticsData::Requests", :type => :request do

  before(:all) do
    @valid_token = FactoryGirl.create(:token).access_token
    
    @user = FactoryGirl.create(:user)
    @user.add_uuid_and_origin_url

    @story = FactoryGirl.create(:story)    
    @story.reads = 10
    @story.downloads = 3
    @story.high_resolution_downloads = 12
    @story.epub_downloads = 6
    @story.save!

    @illustration = FactoryGirl.create(:illustration)
    @illustration.reads = 20
    @illustration.save!

    @second_illustration = FactoryGirl.create(:illustration)
    @second_illustration.reads = 15
    @second_illustration.save!
    @second_illustration.origin_url = "https://www.awesome-website.com"
    @second_illustration.uuid = "AWW-1"
    @second_illustration.save!

    [1, 2, 1].each do |illustration_id|
      illustration_download = IllustrationDownload.new
      illustration_download.user = @user
      illustration_download.download_type = "original"
      illustration_download.ip_address = "192.168.0.1"
      #illustration_download.organization_user = false
      illustration_download.illustration_id = illustration_id
      illustration_download.save!
    end

    # Adding one page with a crop to the already created story
    @front_cover_page = FactoryGirl.create(:front_cover_page)
    @illustration_crop_with_image = FactoryGirl.create(:illustration_crop_with_image)
    @front_cover_page.illustration_crop = @illustration_crop_with_image
    @front_cover_page.save!
    @story.pages = [@front_cover_page]
    @story.save!

    @first_derivation_story = FactoryGirl.create(:story)
    @first_derivation_story.parent = @story
    @first_derivation_story.save!

    @translated_story = FactoryGirl.create(:story)
    @translated_story.parent = @first_derivation_story
    @translated_story.derivation_type = "translated"
    @translated_story.status = :published
    @translated_story.origin_url = "https://www.awesome-website.com"
    @translated_story.uuid = "AWW-10"
    @translated_story.save!

    @relevelled_story = FactoryGirl.create(:story)
    @relevelled_story.parent = @first_derivation_story
    @relevelled_story.derivation_type = "relevelled"
    @relevelled_story.status = :published
    @relevelled_story.reading_level = '2'
    @relevelled_story.language = @first_derivation_story.language
    @relevelled_story.origin_url = "https://www.awesome-website.com"
    @relevelled_story.uuid = "AWW-12"
    @relevelled_story.save!
  end

  context "GET Read Count of StoryWeaver Stories" do

    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/analytics/story_read_count'
      expect_status(401)
      expect_json(error: 'No token present')
    end
  
    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/analytics/story_read_count', token: "random_token"
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/analytics/story_read_count', token: @expired_token
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 200 status and correct JSON if token is valid" do
      get '/api/v0/analytics/story_read_count', token: @valid_token     
      expect_status(200)
      expect(JSON.parse(response.body)).to eq({"SW-2"=>0, "SW-1"=>10})
    end

  end

  context "GET Download Count for each format of StoryWeaver Stories" do

    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/analytics/story_download_count'
      expect_status(401)
      expect_json(error: 'No token present')
    end
  
    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/analytics/story_download_count', token: "random_token"
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/analytics/story_download_count', token: @expired_token
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 200 status and correct JSON if token is valid" do
      get '/api/v0/analytics/story_download_count', token: @valid_token      
      expect_status(200)
      expect(JSON.parse(response.body)).to eq({
        "SW-2"=>{"low_res_pdf"=>0, "high_res_pdf"=>0, "epub"=>0}, 
        "SW-1"=>{"low_res_pdf"=>3, "high_res_pdf"=>12, "epub"=>6}
      })
    end

  end
  
  context "GET View Count of StoryWeaver Illustrations" do

    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/analytics/illustration_view_count'
      expect_status(401)
      expect_json(error: 'No token present')
    end
  
    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/analytics/illustration_view_count', token: "random_token"
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/analytics/illustration_view_count', token: @expired_token
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 200 status and correct JSON if token is valid" do
      get '/api/v0/analytics/illustration_view_count', token: @valid_token      
      expect_status(200)
      expect(JSON.parse(response.body)).to eq({"SW-1"=>20, "SW-3"=>0})
    end

  end
  
  context "GET Download Count of StoryWeaver Illustrations" do

    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/analytics/illustration_download_count'
      expect_status(401)
      expect_json(error: 'No token present')
    end
  
    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/analytics/illustration_download_count', token: "random_token"
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/analytics/illustration_download_count', token: @expired_token
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 200 status and correct JSON if token is valid" do
      get '/api/v0/analytics/illustration_download_count', token: @valid_token      
      expect_status(200)
      expect(JSON.parse(response.body)).to eq({"SW-1"=>2, "SW-3"=>0})
    end

  end

  context "GET Count of StoryWeaver Illustrations getting used in stories created at the partner" do

    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/analytics/illustration_reuse_count'
      expect_status(401)
      expect_json(error: 'No token present')
    end
  
    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/analytics/illustration_reuse_count', token: "random_token"
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/analytics/illustration_reuse_count', token: @expired_token
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 200 status and correct JSON if token is valid" do
      get '/api/v0/analytics/illustration_reuse_count', token: @valid_token      
      expect_status(200)
      expect(JSON.parse(response.body)).to eq({"count" => 1})
    end

  end

  context "GET all published, non-SW, translated stories that have SW stories as their root" do

    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/analytics/sw_translated_stories'
      expect_status(401)
      expect_json(error: 'No token present')
    end
  
    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/analytics/sw_translated_stories', token: "random_token"
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/analytics/sw_translated_stories', token: @expired_token
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 200 status and correct JSON if token is valid" do
      get '/api/v0/analytics/sw_translated_stories', token: @valid_token      
      expect_status(200)
      expect(JSON.parse(response.body)).to eq({
        "AWW-10"=>{
          "language"=>"Language 3", 
          "ancestry"=>{"original_story_uuid"=>"SW-1", "derived_story_uuid"=>"SW-2"}
          }
        }
      )
    end

  end

  context "GET all published, non-SW, relevelled stories that have SW stories as their root" do

    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/analytics/sw_relevelled_stories'
      expect_status(401)
      expect_json(error: 'No token present')
    end
  
    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/analytics/sw_relevelled_stories', token: "random_token"
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/analytics/sw_relevelled_stories', token: @expired_token
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 200 status and correct JSON if token is valid" do
      get '/api/v0/analytics/sw_relevelled_stories', token: @valid_token      
      expect_status(200)
      expect(JSON.parse(response.body)).to eq({
        "AWW-12"=>{
          "language"=>"Language 2", 
          "ancestry"=>{"original_story_uuid"=>"SW-1", "derived_story_uuid"=>"SW-2"}
          }
        }
      )
    end

  end

end