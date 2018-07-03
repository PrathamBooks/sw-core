require 'spec_helper'

describe Api::V1::HomeController, :type => :controller do
  render_views
  before(:each) do
    @content_user= FactoryGirl.create(:content_manager)
    @common_user= FactoryGirl.create(:user)
    @list_category = FactoryGirl.create(:list_category)
  end

  let(:json) { JSON.parse(response.body) }

  context "GET current user details" do
    it "should show current user details" do
      sign_in @content_user
      telugu = FactoryGirl.create(:telugu)
      hindi = FactoryGirl.create(:hindi)
      session[:locale] = 'en'
      org1 = FactoryGirl.create(:org_publisher, id: 1)
      phonestory_popup = FactoryGirl.create(:phonestories_popup, user_id: @content_user.id)
      user_popup = FactoryGirl.create(:user_popup, user_id: @content_user.id)
      story1 = FactoryGirl.create(:story, status: Story.statuses[:published])
      Story.reindex
      @content_user.organization_id = org1.id
      @content_user.last_name = "manager"
      @content_user.recommendations = "#{story1.id}"
      @content_user.offline_book_popup_seen = true
      @content_user.language_preferences = "#{telugu.id},#{hindi.id}"
      @content_user.reading_levels = "2,3"
      @content_user.save!
      get :me, format: :json
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("id", "email", "first_name", "last_name", "role", "roles", "isOrganisationMember", "hasHistory", "locale", "isLoggedIn", "bookshelf", "homePopup", "offlineBookPopupSeen", "popupsSeen", "languagePreferences", "readingLevels", "organizationRoles", "downloadLimitReached", "country", "name", "orgName")
      expect_json('data.email', "contentmanager1@test.com")
      expect_json('data.first_name', "contentmanager1")
      expect_json('data.last_name', "manager")
      expect_json('data.role', "content_manager")
      expect_json('data.roles', ["content_manager"])
      expect_json('data.isOrganisationMember', true)
      expect_json('data.hasHistory', true)
      expect_json('data.isLoggedIn', true)
      expect_json('data.homePopup', true)
      expect_json('data.locale', "en")
      expect_json('data.popupsSeen', ["its user popup"])
      expect_json('data.offlineBookPopupSeen', true)
      expect(JSON.parse(response.body)['data']['bookshelf'].keys).to contain_exactly("title", "id", "count", "likeCount", "readCount", "canDelete", "description", "slug", "books")
      expect_json('data.bookshelf.title', 'My Bookshelf')
      expect_json('data.languagePreferences', ["Hindi", "Telugu"])
      expect_json('data.readingLevels', ["2", "3"])
      expect_status(200)
    end
  end
  context "GET current user details if not logged in" do
    it "should show unautorized message" do
      get :me, format: :json
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("isLoggedIn", "locale")
      expect_status(200)
      expect(json).to eq({"ok"=>true, "data"=>{"locale"=>"en", "isLoggedIn"=>false}})
    end
  end

  context "SHOW home page details" do
    it "should show details of bannerImages from home page" do
      create_story
      banner1 = FactoryGirl.create(:banner)
      Story.reindex
      get :banners, format: :json
      expect_json(ok: true)
      expect_json_keys([:ok, :data])
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("bannerImages")
      expect(JSON.parse(response.body)['data']['bannerImages'][0].keys).to contain_exactly("id", "position", "pointToLink", "imageUrls")
      expect_json('data.bannerImages.0.id', 1)
      expect_json('data.bannerImages.0.position', 1)
      expect_json('data.bannerImages.0.pointToLink', 'www.google.com')
      expect(JSON.parse(response.body)['data']['bannerImages'][0]['imageUrls'].keys).to contain_exactly("aspectRatio", "sizes")
      expect_json('data.bannerImages.0.imageUrls.aspectRatio', 3.4026666666666667)
      expect(JSON.parse(response.body)['data']['bannerImages'][0]['imageUrls']['sizes'][0].keys).to contain_exactly("width", "url")
      x = JSON.parse(response.body)["data"]["bannerImages"][0]["imageUrls"]["sizes"][0]["url"]
      expect(x).to start_with('/spec/test_files/banners/')
      expect_status(200)
    end
    it "should show details of editorsPick from home page" do
      create_story
      contest = FactoryGirl.create(:contest)
      story_2 = FactoryGirl.create(:story, :title => "New Story", :status => Story.statuses[:published], :contest_id => contest.id)
      winner = FactoryGirl.create(:winner, :contest_id => contest.id, :story_id => story_2.id)
      Story.reindex
      get :show, format: :json
      expect(JSON.parse(response.body)['data']['editorsPick'].keys).to contain_exactly("meta", "results")
      expect(JSON.parse(response.body)['data']['editorsPick']['meta'].keys).to contain_exactly("hits", "perPage", "page", "totalPages")
      expect_json('data.editorsPick.meta.hits', 2)
      expect_json('data.editorsPick.meta.perPage', 24)
      expect_json('data.editorsPick.meta.page', 1)
      expect_json('data.editorsPick.meta.totalPages', 1)
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0].keys).to contain_exactly("id", "title", "language", "level", "slug", "recommended", "coverImage", "authors", "contest", "editorsPick", "illustrators", "likesCount", "publisher", "readsCount", "description", "availableForOfflineMode", "storyDownloaded")
      expect_json('data.editorsPick.results.0.title', 'Full Story')
      expect_json('data.editorsPick.results.0.language', "English")
      expect_json('data.editorsPick.results.0.level', "1")
      x = JSON.parse(response.body)["data"]["editorsPick"]["results"][0]["slug"]
      expect(x).to end_with("full-story")
      expect_json('data.editorsPick.results.0.recommended', true)
      expect_json('data.editorsPick.results.0.editorsPick', true)
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0]['coverImage'].keys).to contain_exactly("aspectRatio", "cropCoords", "sizes")
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0]['coverImage']['sizes'][0].keys).to contain_exactly("height", "width", "url")
      expect_json('data.editorsPick.results.0.coverImage.sizes.0.height', 100.0)
      expect_json('data.editorsPick.results.0.coverImage.sizes.0.width', 100.0)
      x = JSON.parse(response.body)["data"]["editorsPick"]["results"][0]["coverImage"]["sizes"][0]["url"]
      expect(x).to start_with('/spec/test_files/illustration_crops/')
      expect_json('data.editorsPick.results.0.coverImage.aspectRatio', 1.0)
      expect(JSON.parse(response.body)["data"]["editorsPick"]["results"][0]["coverImage"]["cropCoords"].keys).to contain_exactly("x", "y")
      expect_json('data.editorsPick.results.0.coverImage.cropCoords.x', 0.0)
      expect_json('data.editorsPick.results.0.coverImage.cropCoords.y', 0.0)
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][0]['authors'][0].keys).to contain_exactly("slug", "name")
      x = JSON.parse(response.body)["data"]["editorsPick"]["results"][0]["authors"][0]["slug"]
      expect(x).to end_with("test-user")
      expect_json('data.editorsPick.results.0.authors.0.name', "Test user")
      expect_json('data.editorsPick.results.0.contest', nil)
      expect_json('data.editorsPick.results.1.title', 'New Story')
      expect_json('data.editorsPick.results.1.language', "Language 1")
      expect_json('data.editorsPick.results.1.level', "1")
      expect(JSON.parse(response.body)["data"]["editorsPick"]["results"][1]["slug"]).to end_with("-english-title2")
      expect_json('data.editorsPick.results.1.recommended', false)
      expect_json('data.editorsPick.results.1.editorsPick', false)
      expect(JSON.parse(response.body)['data']['editorsPick']['results'][1]["contest"].keys).to contain_exactly("name", "slug", "won")
      expect_json('data.editorsPick.results.1.contest.name', "contest_story")
      x = JSON.parse(response.body)["data"]["editorsPick"]["results"][1]["contest"]["slug"]
      expect(x).to end_with("contest-story")
      expect_json('data.editorsPick.results.1.contest.won', true)
    end
    it "should show details of newArrivals from home page" do
      create_story
      contest = FactoryGirl.create(:contest)
      story_2 = FactoryGirl.create(:story, :title => "New Story", :status => Story.statuses[:published], :contest_id => contest.id)
      Story.reindex
      get :show, format: :json
      expect(JSON.parse(response.body)['data']['newArrivals']['meta'].keys).to contain_exactly("hits", "perPage", "page", "totalPages")
      expect_json('data.newArrivals.meta.hits', 2)
      expect_json('data.newArrivals.meta.perPage', 24)
      expect_json('data.newArrivals.meta.page', 1)
      expect_json('data.newArrivals.meta.totalPages', 1)
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0].keys).to contain_exactly("id", "title", "language", "level", "slug", "recommended", "coverImage", "authors", "contest", "editorsPick", "illustrators", "likesCount", "publisher", "readsCount", "description", "availableForOfflineMode", "storyDownloaded")
      expect_json('data.newArrivals.results.0.title', 'Full Story')
      expect_json('data.newArrivals.results.0.language', "English")
      expect_json('data.newArrivals.results.0.level', "1")
      x = JSON.parse(response.body)["data"]["newArrivals"]["results"][0]["slug"]
      expect(x).to end_with("full-story")
      expect_json('data.newArrivals.results.0.recommended', true)
      expect_json('data.newArrivals.results.0.editorsPick', true)
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['coverImage'].keys).to contain_exactly("aspectRatio", "cropCoords", "sizes")
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['coverImage']['sizes'][0].keys).to contain_exactly("height", "width", "url")
      expect_json('data.newArrivals.results.0.coverImage.sizes.0.height', 100.0)
      expect_json('data.newArrivals.results.0.coverImage.sizes.0.width', 100.0)
      x = JSON.parse(response.body)["data"]["newArrivals"]["results"][0]["coverImage"]["sizes"][0]["url"]
      expect(x).to start_with('/spec/test_files/illustration_crops/')
      expect_json('data.newArrivals.results.0.coverImage.aspectRatio', 1.0)
      expect(JSON.parse(response.body)["data"]["newArrivals"]["results"][0]["coverImage"]["cropCoords"].keys).to contain_exactly("x", "y")
      expect_json('data.newArrivals.results.0.coverImage.cropCoords.x', 0.0)
      expect_json('data.newArrivals.results.0.coverImage.cropCoords.y', 0.0)
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][0]['authors'][0].keys).to contain_exactly("slug","name")

      x = JSON.parse(response.body)["data"]["newArrivals"]["results"][0]["authors"][0]["slug"]
      expect(x).to end_with("test-user")
      expect_json('data.newArrivals.results.0.authors.0.name', "Test user")
      expect(JSON.parse(response.body)['data']['newArrivals']['results'][1]["contest"].keys).to contain_exactly("name", "slug", "won")
      expect_json('data.newArrivals.results.1.contest.name', "contest_story")
      x = JSON.parse(response.body)["data"]["newArrivals"]["results"][1]["contest"]["slug"]
      expect(x).to end_with("contest-story")
      expect_json('data.newArrivals.results.1.contest.won', false)
    end
    it "should show details of mostRead from home page" do
      story = create_story
      story_2 = FactoryGirl.create(:story, :title => "New Story", :status => Story.statuses[:published], :reads => 100)
      story.reads = 500
      story.save
      Story.reindex
      get :show, format: :json
      expect(JSON.parse(response.body)['data']['mostRead']['meta'].keys).to contain_exactly("hits", "perPage", "page", "totalPages")
      expect_json('data.mostRead.meta.hits', 2)
      expect_json('data.mostRead.meta.perPage', 24)
      expect_json('data.mostRead.meta.page', 1)
      expect_json('data.mostRead.meta.totalPages', 1)
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0].keys).to contain_exactly("id", "title", "language", "level", "slug", "recommended", "coverImage", "authors","contest", "editorsPick", "illustrators", "likesCount", "publisher", "readsCount", "description", "availableForOfflineMode", "storyDownloaded")

      expect_json('data.mostRead.results.0.title', 'Full Story')
      expect_json('data.mostRead.results.0.language', "English")
      expect_json('data.mostRead.results.0.level', "1")
      x = JSON.parse(response.body)["data"]["mostRead"]["results"][0]["slug"]
      expect(x).to end_with("full-story")
      expect_json('data.mostRead.results.0.recommended', true)
      expect_json('data.mostRead.results.0.editorsPick', true)

      expect_json('data.mostRead.results.1.title', 'New Story')
      expect_json('data.mostRead.results.1.language', "Language 1")
      expect_json('data.mostRead.results.1.level', "1")

      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['coverImage'].keys).to contain_exactly("aspectRatio", "cropCoords", "sizes")
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['coverImage']['sizes'][0].keys).to contain_exactly("height", "width", "url")
      expect_json('data.mostRead.results.0.coverImage.sizes.0.height', 100.0)
      expect_json('data.mostRead.results.0.coverImage.sizes.0.width', 100.0)
      x = JSON.parse(response.body)["data"]["mostRead"]["results"][0]["coverImage"]["sizes"][0]["url"]
      expect(x).to start_with('/spec/test_files/illustration_crops/')
      expect_json('data.mostRead.results.0.coverImage.aspectRatio', 1.0)
      expect(JSON.parse(response.body)["data"]["mostRead"]["results"][0]["coverImage"]["cropCoords"].keys).to contain_exactly("x", "y")
      expect_json('data.mostRead.results.0.coverImage.cropCoords.x', 0.0)
      expect_json('data.mostRead.results.0.coverImage.cropCoords.y', 0.0)
      expect(JSON.parse(response.body)['data']['mostRead']['results'][0]['authors'][0].keys).to contain_exactly("slug", "name")

      x = JSON.parse(response.body)["data"]["mostRead"]["results"][0]["authors"][0]["slug"]
      expect(x).to end_with("test-user")
      expect_json('data.mostRead.results.0.authors.0.name', "Test user")
      expect_json('data.mostRead.results.0.contest', nil)
    end
    # need to activate after code stabilized
    it "should show details of blogPosts from home page"
      # do
      #create_story
      #Story.reindex
      #blog_post = FactoryGirl.create(:blog_post, :user => @common_user)
      #get :show, format: :json
      #expect(JSON.parse(response.body)['data']['blogPosts'][0].keys).to contain_exactly("id", "title", "imageUrls", "blogUrl", "description")
      #expect(JSON.parse(response.body)['data']['blogPosts'][0]['imageUrls'].keys).to contain_exactly("aspectRatio", "sizes")
      #expect(JSON.parse(response.body)['data']['blogPosts'][0]['imageUrls']['sizes'][0].keys).to contain_exactly("width", "url")
      #["320", "480", "640", "800", "960", "1120", "1280"].each_with_index do |size,i|
      #x = "data.blogPosts.0.imageUrls.sizes.#{i}.width"
      #expect_json(x, size)
      #x = JSON.parse(response.body)["data"]["blogPosts"][0]["imageUrls"]["sizes"][0]["url"]
      #expect(x).to start_with('/spec/test_files/blog_posts/')
      ##expect_json('data.blogPosts.0.imageUrls.aspectRatio', 1.7)
      #x = JSON.parse(response.body)["data"]["blogPosts"][0]["blogUrl"]
      #expect(x).to end_with("/blog_posts/1")
      #e=expect_json('data.blogPosts.0.imageUrls.description', nil)
    # end
  end

  context "POST subscription details" do
    it "should have subscription" do
      sign_in @common_user
      post :subscription, :email => "test@testing.com", format: :json
      expect_json(ok: true)
      expect_status(200)
    end
    #Need to activate the code after code stabilized, bug raised
    #it "should give error message for invalid email" do
    #  sign_in @common_user
    #  post :subscription, :email => ".test@testing.com", format: :json
    #  expect(json).to eq({"ok"=>false, "data"=>{"errorCode"=>422, "errorMessage"=>"email id is not valid"}})
    #  expect_status(422)
    #end
    #it "should give error message for invalid email" do
    #  sign_in @common_user
    #  post :subscription, :email => "*test@testing.com", format: :json
    #  expect(json).to eq({"ok"=>false, "data"=>{"errorCode"=>422, "errorMessage"=>"email id is not valid"}})
    #  expect_status(422)
    #end
    it "should give error message for invalid email" do
      sign_in @common_user
      post :subscription, :email => "abc", format: :json
      expect(json).to eq({"ok"=>false, "data"=>{"errorCode"=>422, "errorMessage"=>"email id is not valid"}})
      expect_status(422)
    end
    it "should give error message for invalid email" do
      sign_in @common_user
      post :subscription, :email => "abc@.", format: :json
      expect(json).to eq({"ok"=>false, "data"=>{"errorCode"=>422, "errorMessage"=>"email id is not valid"}})
      expect_status(422)
    end
    it "should give error message if email id already subscribed" do
      sign_in @common_user
      post :subscription, :email => "abc@abc.com", format: :json
      expect_json(ok: true)
      expect_status(200)
      post :subscription, :email => "abc@abc.com", format: :json
      expect(json).to eq({"ok"=>false, "data"=>{"errorCode"=>403, "errorMessage"=>"This email is already subscribed"}})
      expect_status(403)
    end
  end
  context "POST subscription if unauthorized" do
    it "should not do subscription" do
      post :me, format: :json
      expect_json(ok: true)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("isLoggedIn", "locale")
      expect_status(200)
      expect(json).to eq({"ok"=>true, "data"=>{"isLoggedIn"=>false, "locale"=>"en"}})
    end
  end
  context "GET recommendation" do
    it "should show recommendations for signed-in user without recommendation string" do
      sign_in @common_user
      story_list = FactoryGirl.create_list(:story, 11, status: Story.statuses[:published])
      Story.reindex
      FactoryGirl.create_list(:story_read, 10, story_id: story_list[9].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 9, story_id: story_list[2].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 11, story_id: story_list[3].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 12, story_id: story_list[4].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 18, story_id: story_list[5].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 1, story_id: story_list[6].id, user_id: User.first.id)
      get :recommendations, format: :json
      expect_json(ok: true)
      expect(JSON.parse(response.body).keys).to contain_exactly("ok", "data")
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("recommendedStories")
      expect_json('data.recommendedStories.0.title', "Title6")
      expect_json('data.recommendedStories.2.title', "Title4")
      expect_status(200)
    end

    it "should show most read stories for signed-in user with recommendation string" do
      sign_in @common_user
      story_list = FactoryGirl.create_list(:story, 11, status: Story.statuses[:published])
      Story.reindex
      @common_user.recommendations = "#{story_list[10].id},#{story_list[7].id},#{story_list[6].id},#{story_list[2].id},#{story_list[5].id},#{story_list[8].id},#{story_list[9].id},#{story_list[1].id},#{story_list[3].id},#{story_list[0].id},#{story_list[4].id}"
      @common_user.save!
      get :recommendations, format: :json
      expect_json(ok: true)
      expect(JSON.parse(response.body).keys).to contain_exactly("ok", "data")
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("recommendedStories")
      expect_json('data.recommendedStories.2.title', "#{story_list[6].title}")
      expect_json('data.recommendedStories.9.title', "#{story_list[0].title}")
      expect_status(200)
    end
    it "should show most read stories when not signed-in" do
      story_list = FactoryGirl.create_list(:story, 11, status: Story.statuses[:published])
      Story.reindex
      FactoryGirl.create_list(:story_read, 10, story_id: story_list[9].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 9, story_id: story_list[2].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 11, story_id: story_list[3].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 12, story_id: story_list[4].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 18, story_id: story_list[5].id, user_id: User.first.id)
      FactoryGirl.create_list(:story_read, 1, story_id: story_list[6].id, user_id: User.first.id)
      get :recommendations, format: :json
      expect_json(ok: true)
      expect(JSON.parse(response.body).keys).to contain_exactly("ok", "data")
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("recommendedStories")
      expect_json('data.recommendedStories.3.title', "Title10")
      expect_json('data.recommendedStories.5.title', "Title7")
      expect_status(200)
    end
  end
  context "GET disable_notice" do
    it "should disable_notice in home page" do
      session[:submitted_story_notice] = true
      get :disable_notice, format: :json
      expect_json(ok: true)
      expect_status(200)
      session[:submitted_story_notice] = false
      get :disable_notice, format: :json
      expect_json(ok: false)
      expect(JSON.parse(response.body).keys).to contain_exactly("ok", "data")
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly('errorCode', 'errorMessage')
      expect_json('data.errorCode', 404)
      expect_json('data.errorMessage', 'submitted_story_notice flag not set')
    end
  end
  context "GET home categories" do
    #in categories.json.jbuilder file its taking as I18n.t("categories."+cat.name), code change required.
    it "should show categories in home page"
    # do
    #   @story_category = FactoryGirl.create_list(:story_category, 5, )
    #   sc = StoryCategory.all
    #   sc.each do|s|
    #     ss = s.translation
    #     ss.translated_name = ss.name
    #     ss.save!
    #   end[0]
    #   get :categories, format: :json
    #   expect((@story_category).count).to eq(5)
    #   expect_status(200)
    #   expect_json(ok: true)
    #   expect(JSON.parse(response.body).keys).to contain_exactly("ok", "data")
    #   expect(JSON.parse(response.body)['data'][0].keys).to contain_exactly('name', 'queryValue', 'slug', 'imageUrls')
    #   expect(JSON.parse(response.body)['data'][0]['name']).to start_with('Category')
    #   expect(JSON.parse(response.body)['data'][0]['queryValue']).to start_with('Category')
    #   expect(response.body).to match('-category-')
    #   expect(JSON.parse(response.body)['data'][0]['imageUrls'].keys).to contain_exactly('aspectRatio', 'sizes')
    #   expect_json('data.0.imageUrls.aspectRatio', 2.3384615384615386)
    #   expect(JSON.parse(response.body)['data'][0]['imageUrls']['sizes'][0].keys).to contain_exactly('width', 'url')
    #   expect_json('data.0.imageUrls.sizes.0.width', "240")
    #   expect(JSON.parse(response.body)['data'][0]['imageUrls']['sizes'][0]['url']).to start_with('/assets/size_1/')
    # end
  end
  context "GET all categories" do
    it "should show all categories" do
      @story_category = FactoryGirl.create_list(:story_category, 5)
      get :get_categories, format: :json
      expect((@story_category).count).to eq(5)
      expect_status(200)
    end
  end
end
