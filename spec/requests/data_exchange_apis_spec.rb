require "spec_helper"

describe "Api::V0::DataExchange::Requests", :type => :request do

  before(:all) do
    DatabaseCleaner.clean_with(:truncation)

    @valid_token = FactoryGirl.create(:token).access_token
    
    @story = FactoryGirl.create(:english_story)    

    # TODO: better way of adding UUIDs
    @user = User.find(1)
    @user.add_uuid_and_origin_url

    @story_category = StoryCategory.find_by_uuid("SW-1")
    
    @organization = FactoryGirl.create(:org_publisher_with_logo)

    @illustration_style = FactoryGirl.create(:style)

    @illustration_category = FactoryGirl.create(:illustration_category)

    @illustration = FactoryGirl.create(:illustration)

    @illustration_crop = FactoryGirl.create(:illustration_crop)    

    @illustrator = FactoryGirl.create(:person_with_account)
    @illustrator.user.add_uuid_and_origin_url

    @story_category_with_banner_and_home_image = FactoryGirl.create(:story_category_with_banner_and_home_image)

    # Adding one page with a crop to the already created story
    @front_cover_page = FactoryGirl.create(:front_cover_page)
    @illustration_crop_with_image = FactoryGirl.create(:illustration_crop_with_image)
    @front_cover_page.illustration_crop = @illustration_crop_with_image
    @front_cover_page.save!
    @story.pages = [@front_cover_page]
    @story.save!

    # generate ePUB, low-res and high-res PDFs for the story
    StoriesController.new.make_story_static_files(@story)
  end

  context "GET User" do

    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/user/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end
  
    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/user/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/user/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if user with given UUID doesn't exist" do
      get '/api/v0/user/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and user data if user with given UUID found" do
      get '/api/v0/user/SW-1', token: @valid_token, format: :json
      expect_status(200)
      test_hash = {
        "first_name"  => @user.first_name,
        "last_name"   => @user.last_name,
        "uuid"        => @user.uuid
      }
      test_hash.each {|k,v| expect(JSON.parse(response.body)[k]).to eq(v)}
    end

  end

  context "GET Organization" do
  
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/organization/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/organization/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/organization/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if user with given UUID doesn't exist" do
      get '/api/v0/organization/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and organization data if organization with given UUID found" do
      get '/api/v0/organization/SW-1', token: @valid_token, format: :json
      expect_status(200)
      test_hash = {
        "logo_path"           => @organization.logo.path,
        "organization_name"   => @organization.organization_name,
        "translated_name"     => @organization.translated_name,
        "organization_type"   => @organization.organization_type,
        "country"             => @organization.country,
        "city"                => @organization.city,
        "number_of_classrooms"=> @organization.number_of_classrooms,
        "children_impacted"   => @organization.children_impacted,
        "status"              => @organization.status,
        "description"         => @organization.description,
        "website"             => @organization.website,
        "facebook_url"        => @organization.facebook_url,
        "rss_url"             => @organization.rss_url,
        "twitter_url"         => @organization.twitter_url,
        "youtube_url"         => @organization.youtube_url,
        "uuid"                => @organization.uuid
      }
      test_hash.each {|k,v| expect(JSON.parse(response.body)[k]).to eq(v)}
    end

  end

  context "GET Organization Logo" do
    
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/organization_logo/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/organization_logo/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/organization_logo/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if organization with given UUID doesn't exist" do
      get '/api/v0/organization_logo/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and organization logo if organization with given UUID found" do
      get '/api/v0/organization_logo/SW-1', token: @valid_token, format: :json
      expect_status(200)
      expect(response.headers["Content-Type"]).to eq("image/png")
    end
  
  end

  context "GET Illustration Style" do

    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/illustration_style/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/illustration_style/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/illustration_style/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if user with given UUID doesn't exist" do
      get '/api/v0/illustration_style/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and illustration style data if illustration_style with given UUID found" do
      get '/api/v0/illustration_style/SW-1', token: @valid_token, format: :json
      expect_status(200)
      test_hash = {
        "name"            => @illustration_style.name,
        "translated_name" => @illustration_style.translated_name,
        "uuid"            => @illustration_style.uuid
      }
      test_hash.each {|k,v| expect(JSON.parse(response.body)[k]).to eq(v)}
    end
  
  end

  context "GET Illustration Category" do

    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/illustration_category/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/illustration_category/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/illustration_category/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if user with given UUID doesn't exist" do
      get '/api/v0/illustration_category/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and illustration category data if illustration category with given UUID found" do
      get '/api/v0/illustration_category/SW-1', token: @valid_token, format: :json
      expect_status(200)
      test_hash = {
        "name"            => @illustration_category.name,
        "translated_name" => @illustration_category.translated_name,
        "uuid"            => @illustration_category.uuid
      }
      test_hash.each {|k,v| expect(JSON.parse(response.body)[k]).to eq(v)}
    end
  
  end

  context "GET Story Category" do
    
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/story_category/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/story_category/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/story_category/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if user with given UUID doesn't exist" do
      get '/api/v0/story_category/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and story category data if story category with given UUID found" do
      get '/api/v0/story_category/SW-1', token: @valid_token, format: :json
      expect_status(200)
      test_hash = {
        "name"                => @story_category.name,
        "translated_name"     => @story_category.translated_name,
        "private"             => @story_category.private,
        "active_on_home"      => @story_category.active_on_home,
        "uuid"                => @story_category.uuid,
        "banner_path"         => @story_category.category_banner.path,
        "home_image_path"     => @story_category.category_home_image.path
      }
      test_hash.each {|k,v| expect(JSON.parse(response.body)[k]).to eq(v)}
    end
  
  end

  context "GET Story Category Banner" do
    
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/story_category_banner/SW-2', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/story_category_banner/SW-2', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/story_category_banner/SW-2', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if story category with given UUID doesn't exist" do
      get '/api/v0/story_category_banner/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and story category banner if story category with given UUID found" do
      get '/api/v0/story_category_banner/SW-2', token: @valid_token, format: :json
      expect_status(200)
      expect(response.headers["Content-Type"]).to eq("image/jpg")
    end
  
  end

  context "GET Story Category Home Image" do
    
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/story_category_home_image/SW-2', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/story_category_home_image/SW-2', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/story_category_home_image/SW-2', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if story category with given UUID doesn't exist" do
      get '/api/v0/story_category_home_image/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and story category home image if story category with given UUID found" do
      get '/api/v0/story_category_home_image/SW-2', token: @valid_token, format: :json
      expect_status(200)
      expect(response.headers["Content-Type"]).to eq("image/png")
    end
  
  end

  context "GET Story UUID" do

    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/story_uuid/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/story_uuid/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/story_uuid/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if story with given ID doesn't exist" do
      get '/api/v0/story_uuid/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and UUID of story if story with given ID exists" do
      get '/api/v0/story_uuid/1', token: @valid_token, format: :json
      expect_status(200)
      expect(JSON.parse(response.body)["uuid"]).to eq("SW-1")
    end

  end

  context "GET Illustration" do
  
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/illustration/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/illustration/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/illustration/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if illustration with given UUID doesn't exist" do
      get '/api/v0/illustration/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and illustration data if illustration with given UUID found" do
      get '/api/v0/illustration/SW-1', token: @valid_token, format: :json
      expect_status(200)
      if @illustration.uploader_id != nil
        expect(JSON.parse(response.body)["uploader_uuid"]).to eq(@illustration.uploader.uuid)
      end
      test_hash = {
        "styles"              => [{"name"=>"Style2", "translated_name"=>nil}],
        "categories"          => [{"name"=>"Category2", "translated_name"=>nil}],
        "illustrator_uuids"   => @illustration.illustrators.map(&:uuid),
        "name"                => @illustration.name,
        "image_path"          => @illustration.image.path,
        "attribution_text"    => @illustration.attribution_text,
        "license_type"        => @illustration.license_type,
        "image_processing"    => @illustration.image_processing,
        "flaggings_count"     => @illustration.flaggings_count,
        "copy_right_year"     => @illustration.copy_right_year,
        "image_meta"          => @illustration.image_meta,
        "is_pulled_down"      => @illustration.is_pulled_down,
        "image_mode"          => @illustration.image_mode,
        "storage_location"    => @illustration.storage_location,
        "is_bulk_upload"      => @illustration.is_bulk_upload,
        "smart_crop_details"  => @illustration.smart_crop_details,
        "uuid"                => @illustration.uuid
      }
      test_hash.each {|k,v| expect(JSON.parse(response.body)[k]).to eq(v)}
    end
  end

  context "GET Illustration Image" do
    
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/illustration_image/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/illustration_image/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/illustration_image/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if illustration with given UUID doesn't exist" do
      get '/api/v0/illustration_image/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and illustration data if illustration with given UUID found" do
      get '/api/v0/illustration_image/SW-1', token: @valid_token, format: :json
      expect_status(200)
      expect(response.headers["Content-Type"]).to eq("image/jpg")
    end

  end

  context "GET Illustration Crop" do
    
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/illustration_crop/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/illustration_crop/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/illustration_crop/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if illustration crop with given UUID doesn't exist" do
      get '/api/v0/illustration_crop/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and illustration crop data if illustration crop with given UUID found" do
      get '/api/v0/illustration_crop/SW-1', token: @valid_token, format: :json
      expect_status(200)
      if @illustration_crop.illustration_id != nil
        expect(JSON.parse(response.body)["illustration_uuid"]).to eq(@illustration_crop.illustration.uuid)
      end
      test_hash = {
        "image_path"          => @illustration_crop.image.path,
        "image_processing"    => @illustration_crop.image_processing,
        "crop_details"        => @illustration_crop.crop_details,
        "image_meta"          => @illustration_crop.image_meta,
        "storage_location"    => @illustration_crop.storage_location,
        "smart_crop_details"  => @illustration_crop.smart_crop_details,
        "uuid"                => @illustration_crop.uuid
      }
      test_hash.each {|k,v| expect(JSON.parse(response.body)[k]).to eq(v)}
    end
  
  end

  context "GET Illustration Crop Image" do
    
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/illustration_crop_image/SW-2', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/illustration_crop_image/SW-2', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/illustration_crop_image/SW-2', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if illustration crop with given UUID doesn't exist" do
      get '/api/v0/illustration_crop_image/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end

    it "should return 200 status and illustration crop image if illustration crop with given UUID found" do
      get '/api/v0/illustration_crop_image/SW-2', token: @valid_token, format: :json
      expect_status(200)
      expect(response.headers["Content-Type"]).to eq("image/jpg")
    end

  end

  context "GET Illustrator" do
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/illustrator/SW-3', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/illustrator/SW-3', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/illustrator/SW-3', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if illustrator with given UUID doesn't exist" do
      get '/api/v0/illustrator/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end
    
    it "should return 200 status and illustrator data if illustrator with given UUID found" do
      get '/api/v0/illustrator/SW-3', token: @valid_token, format: :json
      expect_status(200)
      if @illustrator.user_id != nil
        expect(JSON.parse(response.body)["user_uuid"]).to eq(@illustrator.user.uuid)
      end
      test_hash = {
        "first_name"  => @illustrator.first_name,
        "last_name"   => @illustrator.last_name,
        "uuid"        => @illustrator.uuid
      }
      test_hash.each {|k,v| expect(JSON.parse(response.body)[k]).to eq(v)}
    end
  end

  context "GET Story PDF" do
    
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/story/pdf/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/story/pdf/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/story/pdf/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if story with given UUID doesn't exist" do
      get '/api/v0/story/pdf/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end
    
    it "should return 200 status and correct response headers if PDF for story with given UUID exists" do
      get '/api/v0/story/pdf/SW-1', token: @valid_token, format: :pdf
      expect_status(200)
      expect(response.headers["Content-Type"]).to eq("application/pdf")
      expect(response.headers["Content-Disposition"]).to eq("attachment; filename=\"1-title1.pdf\"")    
    end	    

  end

  context "GET Story ePUB" do
    
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/story/epub/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/story/epub/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/story/epub/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if story with given UUID doesn't exist" do
      get '/api/v0/story/epub/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end
    
    it "should return 200 status and correct response headers if ePUB for story with given UUID exists" do
      get '/api/v0/story/epub/SW-1', token: @valid_token, format: :epub
      expect_status(200)
      expect(response.headers["Content-Type"]).to eq("application/epub")
      expect(response.headers["Content-Disposition"]).to eq("attachment; filename=\"1-title1.epub\"")    
    end	    

  end

  context "GET Story" do
    
    it "should return 401 status and no token present message if no token passed" do
      get '/api/v0/story/SW-1', format: :json
      expect_status(401)
      expect_json(error: 'No token present')
    end

    it "should return 401 status and incorrect token message if token does not match" do
      get '/api/v0/story/SW-1', token: "random_token", format: :json
      expect_status(401)
      expect_json(error: 'Incorrect token')
    end

    it "should return 401 status and invalid token message if token has expired" do
      @expired_token = FactoryGirl.create(:expired_token).access_token
      get '/api/v0/story/SW-1', token: @expired_token, format: :json
      expect_status(401)
      expect_json(error: 'Invalid token')
    end

    it "should return 404 status and record not found message if story with given UUID doesn't exist" do
      get '/api/v0/story/SW-1010', token: @valid_token, format: :json
      expect_status(404)
      expect_json(error: 'Record not found')
    end
    
    it "should return 200 status and correct response headers if story with given UUID exists" do
      get '/api/v0/story/SW-1', token: @valid_token, format: :json
      expect_status(200)
      if @story.language_id != nil
        expect(JSON.parse(response.body)["language_name"]).to eq(@story.language.name)
      end
      if @story.copy_right_holder_id != nil
        expect(JSON.parse(response.body)["copy_right_holder_uuid"]).to eq(@story.copy_right_holder.uuid)
      end
      if @story.organization_id != nil
        expect(JSON.parse(response.body)["organization_uuid"]).to eq(@story.organization.uuid)
      end
      test_hash = {
        "title"             => @story.title,
        "attribution_text"  => @story.attribution_text,
        "english_title"     => @story.english_title,
        "reading_level"     => @story.reading_level,
        "status"            => @story.status,
        "copy_right_year"   => @story.copy_right_year,
        "synopsis"          => @story.synopsis,
        "story_categories"  => [{"name"=>"Category 1", "translated_name"=>nil}],
        "orientation"       => @story.orientation,
        "more_info"         => @story.more_info,
        "tag_list"          => @story.tag_list,
        "ancestry"          => @story.ancestry,
        "uuid"              => @story.uuid
      }
      expect(JSON.parse(response.body)["pages"][0]["content"]).to eq(@story.pages[0].content)
      expect(JSON.parse(response.body)["pages"][0]["position"]).to eq(@story.pages[0].position)
      expect(JSON.parse(response.body)["pages"][0]["type"]).to eq(@story.pages[0].type)
      expect(JSON.parse(response.body)["pages"][0]["page_template_name"]).to eq(@story.pages[0].page_template.name)
      expect(JSON.parse(response.body)["pages"][0]["illustration_crop_uuid"]).to eq(@story.pages[0].illustration_crop.uuid)
      test_hash.each {|k,v| expect(JSON.parse(response.body)[k]).to eq(v)}
    end	    

  end
end