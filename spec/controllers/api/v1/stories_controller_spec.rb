require 'rails_helper'
require 'spec_helper'

describe Api::V1::StoriesController, :type => :controller do

  render_views
  before(:each) do
    @user= FactoryGirl.create(:user)
    @content_mgr= FactoryGirl.create(:content_manager)
    @list_category = FactoryGirl.create(:list_category)
  end
  let(:json) { JSON.parse(response.body) }

#SHOW
  context "SHOW/GET Story Details" do
    let(:front_cover_page_template) {FactoryGirl.create(:front_cover_page_template,default: true,orientation: 'landscape')}
    let(:back_inner_cover_page_template) {FactoryGirl.create(:back_inner_cover_page_template,default: true,orientation: 'landscape')}
    let(:back_cover_page_template) {FactoryGirl.create(:back_cover_page_template,default: true,orientation: 'landscape')}

    it "should show the story details" do
      sign_in @user
      english = FactoryGirl.create( :english)
      donor = FactoryGirl.create(:donor)
      story1 = FactoryGirl.create(:level_1_story,language: english, :tag_list =>  ["New_tag"], :title => "Original Story", :status => Story.statuses[:published], :editor_recommended => true, recommended_status: 0, :donor_id => donor.id)
      story_page_1 = FactoryGirl.create(:story_page)
      story1.insert_page(story_page_1)
      Story.reindex
      get :show, :id => story1.id, format: :json
      expect(ok: true)
      expect(JSON.parse(response.body)['data'].keys).to contain_exactly("name", "id", "language", "level", "slug", "status", "liked", "description", "isTranslation", "readsCount", "likesCount", "readingListMembershipCount", "copyrightNotice", "orientation", "recommended", "canEdit", "publisher", "publishedTime", "contest", "similarBooks", "translations", "coverImage", "tags", "downloadLinks", "authors", "originalStory", "illustrators", "lists", "isFlagged", "editorsPick", "versionCount", "languageCount", "availableForOfflineMode", "googleFormDownloadLink", "externalLink", "isRelevelled", "photographers", "downloadLimitReached", "categories", "publishedDate", "isAudio", "lastPagePosition", "donor", 'isGif')
      expect(expect_json('data.name', 'Original Story')).to eq(true)
      expect(expect_json('data.language', 'English')).to eq(true)
      expect(expect_json('data.level', '1')).to eq(true)
      x = JSON.parse(response.body)["data"]["slug"]
      expect(x).to end_with("-english-title1")
      expect(expect_json('data.status', 'published')).to eq(true)
      x = JSON.parse(response.body)["data"]["description"]
      expect(expect(x).to start_with("Synopsis")).to eq(true)
      expect_json('data.isTranslation', false)
      expect_json('data.readsCount', 0)
      expect_json('data.likesCount', 0)
      expect_json('data.readingListMembershipCount', 0)
      expect(expect_json('data.copyrightNotice', 'This book has been published on StoryWeaver by rspec')).to eq(true)
      expect(expect_json('data.orientation', 'landscape')).to eq(true)
      expect_json('data.recommended', true)
      expect_json('data.editorsPick', true)
      expect_json('data.canEdit', false)
      expect_json('data.isFlagged', false)
      expect_json('data.isRelevelled', false)
      # Need to add value for photographers after implementation
      expect_json('data.photographers', [])
      expect(JSON.parse(response.body)['data']['publisher'].keys).to contain_exactly("slug", "name", "website", "logo")
      expect_json('data.publisher.slug', nil)
      expect(expect_json('data.publisher.name', 'StoryWeaver Community')).to eq(true)
      expect_json('data.publisher.website', nil)
      expect(expect_json('data.publishedTime','1438079154000')).to eq(true)
      expect_json('data.donor.name', "Test donor")
      expect_json('data.contest', nil)
      expect_json('data.similarBooks.0', nil)
      expect_json('data.translations.0', nil)
      expect(JSON.parse(response.body)['data']['coverImage'].keys).to contain_exactly("aspectRatio", "cropCoords", "sizes")
      expect_json('data.coverImage.aspectRatio', 1.0)
      expect_json('data.coverImage.cropCoords', {:x => 0, :y => 0})
      expect_json('data.coverImage.sizes.0.url', nil)

      expect(JSON.parse(response.body)["data"]["tags"][0].keys).to contain_exactly("name", "query")
      expect_json('data.tags.0.name', 'New_tag')
      expect_json('data.tags.0.query', 'New_tag')
      expect(JSON.parse(response.body)["data"]["downloadLinks"][0].keys).to contain_exactly("type", "href")
      expect_json('data.downloadLinks.0.type', 'PDF')
      x = JSON.parse(response.body)["data"]["downloadLinks"][0]["href"]
      expect(x).to end_with("-original-story.pdf")
      expect_json('data.googleFormDownloadLink', 'https://docs.google.com/forms/d/e/1FAIpQLSemX06BAWeaIOBR_wmjwNCHQHz16EqVq6VCYPAGTVTQacbA6A/viewform')
      expect(JSON.parse(response.body)['data']['authors'][0].keys).to contain_exactly("id", "name", "slug")
      expect(expect_json('data.authors.0.name', 'User2 User Last name 2')).to eq(true)
      x = JSON.parse(response.body)['data']['authors'][0]['slug']
      expect(x).to end_with('-user2-user-last-name-2')

      expect(JSON.parse(response.body)['data']['originalStory'].keys).to contain_exactly("id", "name", "slug", "authors")
      expect(expect_json('data.originalStory.name', 'Original Story')).to eq(true)
      x = JSON.parse(response.body)["data"]["originalStory"]["slug"]
      expect(x).to end_with("-english-title1")
      expect(JSON.parse(response.body)['data']['originalStory']['authors'][0].keys).to contain_exactly("id", "name", "slug")
      expect(expect_json('data.originalStory.authors.0.name', 'User2 User Last name 2')).to eq(true)
      x = JSON.parse(response.body)['data']['originalStory']['authors'][0]['slug']
      expect(x).to end_with('-user2-user-last-name-2')

      expect_json('data.illustrators.0', nil)
      expect_json('data.list', nil)
      expect(response).to be_success
      expect_status(200)
    end

    it "should show the story can be editable only by same author or by content manager" do
      sign_in @user
      story1 = FactoryGirl.create(:level_1_story, :title => "Original Story", :status => Story.statuses[:published], :authors => [@user])
      story_page_1 = FactoryGirl.create(:story_page)
      story1.insert_page(story_page_1)
      Story.reindex
      get :show, :id => story1.id, format: :json
      expect_json('data.canEdit', true)
      sign_out @user
      sign_in @content_mgr
      story1 = FactoryGirl.create(:level_1_story, :title => "Original Story1", :status => Story.statuses[:published])
      story_page_1 = FactoryGirl.create(:story_page)
      story1.insert_page(story_page_1)
      Story.reindex
      get :show, :id => story1.id, format: :json
      expect_json('data.canEdit', true)
      sign_out @content_mgr
      #login with other user
      @diff_user = FactoryGirl.create(:user)
      sign_in @diff_user
      story1 = FactoryGirl.create(:level_1_story, :title => "Original Story", :status => Story.statuses[:published], :authors => [@user])
      story_page_1 = FactoryGirl.create(:story_page)
      story1.insert_page(story_page_1)
      Story.reindex
      get :show, :id => story1.id, format: :json
      expect_json('data.canEdit', false)
    end

    it "should show the story read and likes count" do
      sign_in @user
      user1 = FactoryGirl.create(:user, :name => "Test user")
      story1 = FactoryGirl.create(:level_1_story, :title => "Original Story", :authors => [@user], :status => Story.statuses[:published], :reads => 5)
      6.times {story1.liked_by FactoryGirl.create(:user)}
      story_page_1 = FactoryGirl.create(:story_page)
      story1.insert_page(story_page_1)
      Story.reindex
      get :show, :id => story1.id, format: :json
      expect_json('data.readsCount', 5)
      expect_json('data.likesCount', 6)
    end

    it "should show the story as flagged" do
      sign_in @user
      user1 = FactoryGirl.create(:user, :name => "Test user")
      story1 = FactoryGirl.create(:level_1_story, :title => "Original Story", :authors => [@user], :status => Story.statuses[:published])
      story_page_1 = FactoryGirl.create(:story_page)
      story1.insert_page(story_page_1)
      @user.flag(story1, "Flagged Story")
      Story.reindex
      get :show, :id => story1.id, format: :json
      expect_json('data.isFlagged', true)
    end

    it "should show the story publisher details" do
      sign_in @user
      org1 = FactoryGirl.create(:org_publisher, id: 1)
      @pub1= FactoryGirl.create(:publisher_org, organization_id: org1.id)
      story1 = FactoryGirl.create(:level_1_story, :title => "Original Story", :status => Story.statuses[:published], :organization_id => org1.id)
      story_page_1 = FactoryGirl.create(:story_page)
      story1.insert_page(story_page_1)
      Story.reindex
      get :show, :id => story1.id, format: :json
      expect(JSON.parse(response.body)['data']['publisher'].keys).to contain_exactly("slug", "name", "website", "logo")
      x = JSON.parse(response.body)["data"]["publisher"]["slug"]
      expect(x).to end_with("-org_publisher_name-1")
      expect(expect_json('data.publisher.name', 'org_publisher_name 1')).to eq(true)
      expect(expect_json('data.publisher.website', 'www.storyweaver.org')).to eq(true)
    end

    it "should show the story donorName details" do
      sign_in @user
      donor = FactoryGirl.create(:donor)
      story1 = FactoryGirl.create(:level_1_story, :title => "Original Story", :status => Story.statuses[:published], :donor_id => donor.id)
      story_page_1 = FactoryGirl.create(:story_page)
      story1.insert_page(story_page_1)
      Story.reindex
      get :show, :id => story1.id, format: :json
      expect(expect_json('data.donor.name', 'Test donor')).to eq(true)
    end

    it "should show the story contest details" do
      sign_in @user
      contest = FactoryGirl.create(:contest)
      story1 = FactoryGirl.create(:level_1_story, :title => "Original Story", :status => Story.statuses[:published], :contest_id => contest.id)
      story_page_1 = FactoryGirl.create(:story_page)
      story1.insert_page(story_page_1)
      winner = FactoryGirl.create(:winner, :contest_id => contest.id, :story_id => story1.id)
      Story.reindex
      get :show, :id => story1.id, format: :json
      expect(JSON.parse(response.body)['data']["contest"].keys).to contain_exactly("name", "slug", "won")
      expect(expect_json('data.contest.name', "contest_story")).to eq(true)
      x = JSON.parse(response.body)["data"]["contest"]["slug"]
      expect(x).to end_with("contest-story")
      expect_json('data.contest.won', true)
    end

    it "should show similar stories" do
      english = FactoryGirl.create( :english)
      hindi = FactoryGirl.create( :hindi)
      organization = FactoryGirl.create(:org_publisher, id: 1)
      publisher= FactoryGirl.create(:publisher_org, organization_id: organization.id)
      cat_1 = FactoryGirl.create(:story_category, name:  "cat_1")
      cat_2 = FactoryGirl.create(:story_category, name:  "cat_2")
      story1 = FactoryGirl.create(:level_1_story, language: english, :title => "Original Story", categories: [cat_2], :status => Story.statuses[:published])
      story_page_1 = FactoryGirl.create(:story_page)
      story1.insert_page(story_page_1)
      similar_story1 = FactoryGirl.create(:level_2_story,language: english, categories: [cat_2], :status => Story.statuses[:published], organization: organization)
      similar_story2 = FactoryGirl.create(:level_1_story,language: english, categories: [cat_2], :status => Story.statuses[:published], organization: organization)
      Story.reindex
      get :show, :id => story1.id, format: :json
      expect(JSON.parse(response.body)['data']['similarBooks'][0].keys).to contain_exactly("title", "id", "slug", "language", "level", "recommended", "coverImage", "authors", "contest", "editorsPick", "illustrators", "likesCount", "publisher", "readsCount", "description", "availableForOfflineMode", "storyDownloaded", "isAudio", "audioStatus", 'isGif')
      expect(JSON.parse(response.body)['data']['similarBooks'][0]['coverImage'].keys).to contain_exactly("aspectRatio", "cropCoords", "sizes")
      expect(JSON.parse(response.body)['data']['similarBooks'][0]['authors'][0].keys).to contain_exactly("slug", "name")
      expect_json('data.similarBooks.0.title', 'Level 1 Story Title')
      expect_json('data.similarBooks.0.language', 'English')
      expect_json('data.similarBooks.0.level', '1')
      x = JSON.parse(response.body)["data"]["similarBooks"][0]["slug"]
      expect(x).to end_with("-level-1-story-title")
      expect_json('data.similarBooks.0.recommended', false)
      expect_json('data.similarBooks.0.editorsPick', false)
      expect_json('data.similarBooks.0.storyDownloaded', false)
      expect_json('data.similarBooks.0.coverImage.aspectRatio', 1.0)
      expect_json('data.similarBooks.0.coverImage.cropCoords', {:x => 0, :y => 0})
      expect_json('data.similarBooks.0.coverImage.sizes.0.url', nil)
      expect_json('data.similarBooks.0.authors.0.name', 'User5 User Last name 5')
    end

    it "should show the Original and translation story details with illustration" do
      sign_in @user
      user1 = FactoryGirl.create(:user, :name => "Test user")
      person = FactoryGirl.create(:person_with_account, :user => user1)
      english = FactoryGirl.create( :english)
      kannada = FactoryGirl.create( :kannada)
      illustration = FactoryGirl.create(:illustration, :illustrators => [person])
      story1 = create_story({story_title: "Original Story", illustration: illustration, language: english})
      translated_story1 = story1.new_derivation(FactoryGirl.attributes_for(:story, title: "Translated_story1", language_id: kannada.id).slice!(:id), story1.authors.first, story1.authors.first, "translated")
      translated_story1.save!
      Story.reindex
      Illustration.reindex
      get :show, :id => story1.id, format: :json
      expect(JSON.parse(response.body)['data']['translations'][0].keys).to contain_exactly("title", "id", "slug", "language", "level", "recommended")
      expect(expect_json('data.translations.0.title', 'Translated_story1')).to eq(true)
      x = JSON.parse(response.body)["data"]["translations"][0]["slug"]
      expect(x).to end_with("-english-title2")
      expect(expect_json('data.translations.0.language', 'Kannada')).to eq(true)
      expect(expect_json('data.translations.0.level', '1')).to eq(true)
      expect(JSON.parse(response.body)['data']['coverImage'].keys).to contain_exactly("aspectRatio", "cropCoords", "sizes")
      expect(expect_json('data.coverImage.aspectRatio', 1.0)).to eq(true)
      expect(JSON.parse(response.body)['data']['coverImage']['cropCoords'].keys).to contain_exactly("x", "y")
      expect_json('data.coverImage.cropCoords.x', 0)
      expect_json('data.coverImage.cropCoords.y', 0)
      expect(JSON.parse(response.body)['data']['coverImage']['sizes'][0].keys).to contain_exactly("height", "width", "url")
      expect(expect_json('data.coverImage.sizes.0.height', 100.0)).to eq(true)

      expect(expect_json('data.coverImage.sizes.0.width', 100.0)).to eq(true)
      x = JSON.parse(response.body)["data"]["coverImage"]["sizes"][0]["url"]
      expect(x).to start_with("/spec/test_files/illustration_crops/")

      #Original_story details
      expect(JSON.parse(response.body)["data"]["downloadLinks"][0].keys).to contain_exactly("type", "href")
      expect_json('data.downloadLinks.0.type', "PDF")
      x = JSON.parse(response.body)["data"]["downloadLinks"][0]["href"]
      expect(x).to end_with("-original-story.pdf")
      expect(JSON.parse(response.body)['data']['authors'][0].keys).to contain_exactly("id", "name", "slug")
      expect(expect_json('data.authors.0.name', 'Test user')).to eq(true)
      x = JSON.parse(response.body)['data']['authors'][0]['slug']
      expect(x).to end_with('-test-user')

      expect(JSON.parse(response.body)['data']['originalStory'].keys).to contain_exactly("id", "name", "slug", "authors")
      expect(expect_json('data.originalStory.name', 'Original Story')).to eq(true)
      x = JSON.parse(response.body)["data"]["originalStory"]["slug"]
      expect(x).to end_with("-english-title1")
      expect(JSON.parse(response.body)['data']['originalStory']['authors'][0].keys).to contain_exactly("id", "name", "slug")
      expect(expect_json('data.originalStory.authors.0.name', 'Test user')).to eq(true)
      x = JSON.parse(response.body)['data']['originalStory']['authors'][0]['slug']
      expect(x).to end_with('-test-user')

      #illustrators
      expect(JSON.parse(response.body)['data']['illustrators'][0].keys).to contain_exactly("id", "name", "slug")
      expect(expect_json('data.illustrators.0.name', 'Test user')).to eq(true)
      x = JSON.parse(response.body)['data']['illustrators'][0]['slug']
      expect(x).to end_with('-test-user')
    end

    it "should show list stories" do
      sign_in @user
      list= FactoryGirl.create(:list, user: @user, :title => "List one")
      story1 = FactoryGirl.create(:level_1_story, :title => "Original Story", :status => Story.statuses[:published])
      story_page_1 = FactoryGirl.create(:story_page)
      story1.insert_page(story_page_1)
      list.stories << story1
      Story.reindex
      List.reindex
      get :show, :id => story1.id, format: :json
      expect_json('data.readingListMembershipCount', 1)
      x = JSON.parse(response.body)['data']['lists'][0]['slug']
      expect(x).to end_with('-list-one')
    end

    it "should show the story details for translation" do
      english = FactoryGirl.create( :english)
      kannada = FactoryGirl.create( :kannada)
      person = FactoryGirl.create(:person_with_account, :user => @user)
      illustration = FactoryGirl.create(:illustration, :illustrators => [person])
      similar_story1 = FactoryGirl.create(:level_1_story,language: english, :tag_list =>  ["New tag"], :title => "Original Story", :authors => [@user], :status => Story.statuses[:published])
      front_cover_page = FactoryGirl.create(:front_cover_page, story: similar_story1, page_template: front_cover_page_template)
      generate_illustration_crop(front_cover_page, illustration)
      story_page_1 = FactoryGirl.create(:story_page)
      similar_story1.insert_page(story_page_1)
      back_inner_cover_page = FactoryGirl.create(:back_inner_cover_page, story: similar_story1, page_template: back_inner_cover_page_template)
      back_cover_page = FactoryGirl.create(:back_cover_page, story: similar_story1, page_template: back_cover_page_template)
      similar_story1.build_book
      similar_story1.save
      translated_story1 = similar_story1.new_derivation(FactoryGirl.attributes_for(:story, title: "Translated_story1", language_id: kannada.id).slice!(:id), similar_story1.authors.first, similar_story1.authors.first, "translated")
      translated_story1.save!
      Illustration.reindex
      Story.reindex
      get :show, :id => translated_story1.id, format: :json
      expect_json(ok: true)
      expect(expect_json('data.name', 'Translated_story1')).to eq(true)
      expect_json('data.isTranslation', true)
    end

    context "download links for stories for various users" do
      before(:each) do
        @download_keys = ['ePub', 'PDF', 'HiRes PDF']
        @english = FactoryGirl.create(:english)
        @test_user= FactoryGirl.create(:user, :first_name => "Test", :last_name => "user")
        @test_person = FactoryGirl.create(:person, :user => @test_user)
        @story1 = FactoryGirl.create(:level_1_story,language: @english, :tag_list =>  ["New_tag"], :title => "Original Story", :status => Story.statuses[:published], :editor_recommended => true, recommended_status: 0, authors: [@test_user])
        @ill = FactoryGirl.create(:illustration, illustrators: [@test_person])
        @ill_crop = FactoryGirl.create(:illustration_crop, illustration: @ill)
        @story_page_1 = FactoryGirl.create(:story_illustration, story: @story1, :illustration_crop => @ill_crop )
        @story1.insert_page(@story_page_1)
        Story.reindex
        Illustration.reindex
      end

      it "should display all the downloadable links for content manager" do
        sign_in @content_mgr
        get :show, :id => @story1.id, format: :json
        json['data']['downloadLinks'].each do |type|
          expect(type["href"].class).to eql String
        end
        downloadlinks = JSON.parse(response.body)['data']['downloadLinks']
        expect(downloadlinks.count).to eq 3
        expect(@download_keys - downloadlinks.map{|t| t["type"]}).to eq []
      end

      it "should display hires if the story is published by his/her publications for publisher login" do
        pub_org = FactoryGirl.create(:publisher_org)
        test_person = FactoryGirl.create(:person, :user => pub_org)
        own_story = FactoryGirl.create(:level_1_story, language: @english, :tag_list => ["New tag"], :title => "Original Story1", :status => Story.statuses[:published], :editor_recommended => true, recommended_status: 0, :authors => [pub_org])
        ill = FactoryGirl.create(:illustration, illustrators: [test_person])
        ill_crop = FactoryGirl.create(:illustration_crop, illustration: ill)
        story_page_1 = FactoryGirl.create(:story_illustration, illustration_crop: ill_crop, story: own_story)
        own_story.insert_page(story_page_1)
        own_story.save
        User.reindex
        Story.reindex
        Illustration.reindex
        sign_in pub_org
        get :show, :id => own_story.id, format: :json
        json['data']['downloadLinks'].each do |type|
          expect(type["href"].class).to eql String
        end
        downloadlinks = JSON.parse(response.body)['data']['downloadLinks']
        expect(downloadlinks.count).to eq 3
        expect(@download_keys - downloadlinks.map{|t| t["type"]}).to eq []
        get :show, :id => @story1.id, format: :json
        downloadlinks = JSON.parse(response.body)['data']['downloadLinks']
        downloadlinks.each do |type|
          expect(type["href"].class).to eql String
        end
        downloadlinks = JSON.parse(response.body)['data']['downloadLinks']
        expect(downloadlinks.count).to eq 2
        expect(@download_keys - downloadlinks.map{|t| t["type"]}).to eq ['HiRes PDF']
      end

      it "should display hires if the story is owned by his/her for organisation" do
        org = FactoryGirl.create(:org_publisher)
        org_user = FactoryGirl.create(:user, organization: org)
        test_person = FactoryGirl.create(:person, :user => org_user)
        own_story = FactoryGirl.create(:level_1_story, language: @english, :tag_list => ["New tag"], :title => "Original Story1", :status => Story.statuses[:published], :editor_recommended => true, recommended_status: 0, :authors => [org_user],:organization_id => org.id )
        ill = FactoryGirl.create(:illustration, illustrators: [test_person])
        ill_crop = FactoryGirl.create(:illustration_crop, illustration: ill)
        story_page_1 = FactoryGirl.create(:story_illustration, illustration_crop: ill_crop, story: own_story)
        own_story.insert_page(story_page_1)
        own_story.save
        Story.reindex
        sign_in org_user
        get :show, :id => own_story.id, format: :json
        json['data']['downloadLinks'].each do |type|
          expect(type["href"].class).to eql String
        end
        downloadlinks = JSON.parse(response.body)['data']['downloadLinks']
        expect(downloadlinks.count).to eq 3
        get :show, :id => @story1.id, format: :json
        downloadlinks = JSON.parse(response.body)['data']['downloadLinks']
        expect(downloadlinks.count).to eq 2
        expect(@download_keys - downloadlinks.map{|t| t["type"]}).to eq ['HiRes PDF']
        downloadlinks.each do |type|
          expect(type["href"].class).to eql String
        end
      end

      it "should display hires only if it own illustrations and own story when normal user login" do
        user = FactoryGirl.create(:user, first_name: "suresh")
        test_person = FactoryGirl.create(:person, :user => user)
        own_story = FactoryGirl.create(:level_1_story, language: @english, :tag_list => ["New tag"], :title => "Original Story1", :status => Story.statuses[:published], :editor_recommended => true, recommended_status: 0, :authors => [user])
        ill = FactoryGirl.create(:illustration, illustrators: [test_person])
        ill_crop = FactoryGirl.create(:illustration_crop, illustration: ill)
        story_page_1 = FactoryGirl.create(:story_illustration, illustration_crop: ill_crop, story: own_story)
        own_story.insert_page(story_page_1)
        own_story.save
        User.reindex
        Story.reindex
        sign_in user
        get :show, :id => own_story.id, format: :json
        downloadlinks = JSON.parse(response.body)['data']['downloadLinks']
        expect(downloadlinks.count).to eq 3
        expect(@download_keys - downloadlinks.map{|t| t["type"]}).to eq []
        downloadlinks.each do |type|
          expect(type["href"].class).to eql String
        end
        get :show, :id => @story1.id, format: :json
        downloadlinks = JSON.parse(response.body)['data']['downloadLinks']
        expect(downloadlinks.count).to eq 2
        expect(@download_keys - downloadlinks.map{|t| t["type"]}).to eq ['HiRes PDF']
        downloadlinks.each do |type|
          expect(type["href"].class).to eql String
        end
      end

      it "should not display any download links for guest user"  do
        get :show, :id => @story1.id, format: :json
        expect(JSON.parse(response.body)['data']['downloadLinks']).to be_empty
      end
    end
  end

  context "POST/Flag a story" do
    it "should flag a story with reason" do
      sign_in @user
      story = FactoryGirl.create(:story)
      Story.reindex
      expect(Story.first.flaggings_count).to eq(nil)
      post :flag_story, :reasons => ["not-original"], :id => story.id, format: :json
      expect(Story.first.flaggings_count).to eq(1)
      expect_json(ok: true)
      expect_status(200)
    end

    it "should flag a story with reasons as other"  do
       sign_in @user
       story = FactoryGirl.create(:story)
       Story.reindex
       expect(Story.first.flaggings_count).to eq(nil)
       post :flag_story, :reasons => ["other"], :id => story.id, format: :json
       expect(Story.first.flaggings_count).to eq(nil)
       expect_json(ok: false)
       expect_json_keys("data", [:errorCode, :errorMessage])
       expect_status(400)
    end

    it "should flag a story with multiple reasons with one reason as other"  do
       sign_in @user
       story = FactoryGirl.create(:story)
       Story.reindex
       expect(Story.first.flaggings_count).to eq(nil)
       post :flag_story, :reasons => ["not-original", "other"], :id => story.id, format: :json
       expect(Story.first.flaggings_count).to eq(1)
       expect_json(ok: true)
       expect_status(200)
    end

    it "should flag a story with multiple reasons"  do
       sign_in @user
       story = FactoryGirl.create(:story)
       expect(Story.first.flaggings_count).to eq(nil)
       post :flag_story, :reasons => ["not-original", "Sample reason"], :id => story.id, format: :json
       expect(Story.first.flaggings_count).to eq(1)
       expect_json(ok: true)
       expect_status(200)
    end

    it "should flag a story with other reason" do
      sign_in @user
      story = FactoryGirl.create(:story)
      expect(Story.first.flaggings_count).to eq(nil)
      post :flag_story, :reasons => ["other"], :otherReason => "test",:id => story.id, format: :json
      expect(Story.first.flaggings_count).to eq(1)
      expect_json(ok: true)
      expect_status(200)
    end

   it "should not flag a story if reasons and other reasons are empty"  do
       sign_in @user
       story = FactoryGirl.create(:story)
       expect(Story.first.flaggings_count).to eq(nil)
       post :flag_story, :reasons => [], :otherReason => "",:id => story.id, format: :json
       expect(Story.first.flaggings_count).to eq(nil)
       expect_json_keys([:ok, :data])
       expect_json(ok: false)
       expect_json_keys("data", [:errorCode, :errorMessage])
       expect_status(400)
    end

    it "should not flag a story if reason is empty" do
      sign_in @user
      story = FactoryGirl.create(:story)
      expect(Story.first.flaggings_count).to eq(nil)
      post :flag_story, :reasons => [], :id => story.id, format: :json
      expect(Story.first.flaggings_count).to eq(nil)
      expect_json_keys([:ok, :data])
      expect_json(ok: false)
      expect_json_keys("data", [:errorCode, :errorMessage])
      expect_status(400)
    end

    it "should not flag a story if otherReason is empty" do
      sign_in @user
      story = FactoryGirl.create(:story)
      expect(Story.first.flaggings_count).to eq(nil)
      post :flag_story, :otherReason => "", :id => story.id, format: :json
      expect(Story.first.flaggings_count).to eq(nil)
      expect_json_keys([:ok, :data])
      expect_json(ok: false)
      expect_json_keys("data", [:errorCode, :errorMessage])
      expect_status(400)
    end

    it "should flag a story with otherReason" do
      sign_in @user
      story = FactoryGirl.create(:story)
      expect(Story.first.flaggings_count).to eq(nil)
      post :flag_story, :otherReason => "test", :id => story.id, format: :json
      expect(Story.first.flaggings_count).to eq(nil)
      expect_json_keys([:ok, :data])
      expect_json(ok: false)
      expect_json_keys("data", [:errorCode, :errorMessage])
      expect_status(400)
    end
  end

   context "POST/Like a story with current user and different user" do
    it "should be able to like a story" do
      sign_in @user
      story = FactoryGirl.create(:story, id: 1000)
      story_page_1 = FactoryGirl.create(:story_page)
      story.insert_page(story_page_1)
      Story.reindex
      expect(Story.find(1000).cached_votes_total).to eq(0)
      get :show, :id => story.id, format: :json
      expect_json('data.liked', false)
      expect_json('data.likesCount', 0)
      post :story_like, :id => story.id, format: :json
      expect_json(ok: true)
      get :show, :id => story.id, format: :json
      expect_json('data.liked', true)
      expect_json('data.likesCount', 1)

      #same user cannot like the story more than one time - likescount should not increase
      post :story_like, :id => story.id, format: :json
      expect_json(ok: true)
      get :show, :id => story.id, format: :json
      expect_json('data.liked', true)
      expect_json('data.likesCount', 1)
      expect(Story.find(1000).cached_votes_total).to eq(1)

      #likesCount has to increase if its different user
      sign_out @user
      @diff_user= FactoryGirl.create(:user)
      sign_in @diff_user
      post :story_like, :id => story.id, format: :json
      expect_json(ok: true)
      get :show, :id => story.id, format: :json
      expect_json('data.liked', true)
      expect_json('data.likesCount', 2)
      expect(Story.find(1000).cached_votes_total).to eq(2)
      expect_status(200)
    end
  end

  context "POST/Flag a story with current user and different user" do
    it "should be able to flag a story with different user" do
      sign_in @user
      story = FactoryGirl.create(:story, id: 1000)
      expect(Story.find(1000).flaggings_count).to eq(nil)
      post :flag_story, :reasons => ["other"], :otherReason => "test",:id => story.id, format: :json
      expect(Story.find(1000).flaggings_count).to eq(1)
      sign_out @user
      @diff_user= FactoryGirl.create(:user)
      sign_in @diff_user
      post :flag_story, :reasons => ["other"], :otherReason => "test",:id => story.id, format: :json
      expect(Story.find(1000).flaggings_count).to eq(2)
      expect_json(ok: true)
      expect_status(200)
    end

    it "should not be able to flag a story with current user" do
      sign_in @user
      story = FactoryGirl.create(:story)
      expect(Story.first.flaggings_count).to eq(nil)
      post :flag_story, :reasons => ["other"], :otherReason => "test",:id => story.id, format: :json
      expect(Story.first.flaggings_count).to eq(1)
      sign_in @user
      post :flag_story, :reasons => ["other"], :otherReason => "test",:id => story.id, format: :json
      expect(Story.first.flaggings_count).to eq(1)
      expect_json(ok: false)
      expect_status(422)
    end
  end

  context "Read story" do
    let(:front_cover_page_template) {FactoryGirl.create(:front_cover_page_template,default: true,orientation: 'landscape')}
    let(:back_inner_cover_page_template) {FactoryGirl.create(:back_inner_cover_page_template,default: true,orientation: 'landscape')}
    let(:back_cover_page_template) {FactoryGirl.create(:back_cover_page_template,default: true,orientation: 'landscape')}

    it "should read a story" do
      sign_in @user
      @original_story = FactoryGirl.create(:story, status: Story.statuses[:published], editor_recommended: true)
      @front_cover_page = FactoryGirl.create(:front_cover_page, story: @original_story, page_template: front_cover_page_template)
      generate_illustration_crop(@front_cover_page)
      story_page_1 = FactoryGirl.create(:story_page)
      story_page_2 = FactoryGirl.create(:story_page)
      @original_story.insert_page(story_page_1)
      @original_story.insert_page(story_page_2)
      @back_inner_cover_page = FactoryGirl.create(:back_inner_cover_page, story: @original_story, page_template: back_inner_cover_page_template)
      @back_cover_page = FactoryGirl.create(:back_cover_page, story: @original_story, page_template: back_cover_page_template)
      @original_story.build_book
      @original_story.save
      Story.reindex
      get :story_read, :id => @original_story.id, format: :json
      expect_json(ok: true)
      expect_status(200)
      expect_json_keys([:ok, :data])
      expect_json_keys('data', [:levelBand, :publisherLogo, :pages, :css])
      expect(expect_json('data.pages.0.pageType', "FrontCoverPage")).to eq(true)
      expect(expect_json('data.pages.1.pageType', "StoryPage")).to eq(true)
      expect(expect_json('data.pages.3.pageType', "BackInnerCoverPage")).to eq(true)
      expect(response.body).to match('/assets/level_bands/Level')
    end

    it "should return story read level and slug" do
      story = FactoryGirl.create(:story, status: Story.statuses[:published], editor_recommended: true, reading_level: "3")
      Story.reindex
      get :story_read, :id => story.id, format: :json
      expect(json['data'].has_key? 'level').to be true
      expect(json['data'].has_key? 'slug').to be true
      expect(json['data']['level']).to eq story.reading_level
      expect(json['data']['slug'].class).to eql String
    end
  end

  #add_to_editor_picks
  context "POST/story to add_to_editor_picks" do
    it "should be able to add a story to editors_pick if the current user is content manager" do
      sign_in @content_mgr
      story = FactoryGirl.create(:story, title: "original_story", :status => Story.statuses[:published])
      Story.reindex
      post :add_to_editor_picks, :id => story.id, format: :json
      expect_json_keys([:ok])
      expect_json(ok: true)
      expect_status(200)
      expect(Story.first.editor_recommended).to eq(true)
    end

    it "should show error message if story has already added to editor picks " do
      sign_in @content_mgr
      story = FactoryGirl.create(:story, title: "Editor_Story", :status => Story.statuses[:published], :editor_recommended => true)
      story_recomnd = FactoryGirl.create(:recommendation, recommendable_id: story.id, recommendable_type: "Story")
      Story.reindex
      post :add_to_editor_picks, :id => story.id, format: :json
      expect_json_keys([:ok, :data])
      expect_json(ok: true)
      expect(expect_json('data', "Story has already added to editor picks")).to eq(true)
      expect_status(200)
      expect(Story.first.editor_recommended).to eq(true)
    end

    it "should not be able to add a story to editors_pick if the current user is not content manager" do
      sign_in @user
      story = FactoryGirl.create(:story, title: "original_story", :status => Story.statuses[:published])
      Story.reindex
      post :add_to_editor_picks, :id => story.id, format: :json
      expect_json_keys([:ok, :data])
      expect_json(ok: false)
      expect_json_keys("data", [:errorCode, :errorMessage])
      expect_status(401)
      expect_json('data.errorMessage', "You are not authorized to perform this action.")
    end
  end

  #remove_from_editor_picks
  context "POST/story to remove_from_editor_picks" do
    it "should be able to remove a story from editors_pick if the current user is content manager" do
      sign_in @content_mgr
      story = FactoryGirl.create(:story, title: "Editor_Story", :status => Story.statuses[:published], :editor_recommended => true)
      story_recomnd = FactoryGirl.create(:recommendation, recommendable_id: story.id, recommendable_type: "Story")
      Story.reindex
      post :remove_from_editor_picks, :id => story.id, format: :json
      expect_json_keys([:ok])
      expect_json(ok: true)
      expect_status(200)
      expect(Story.first.editor_recommended).to eq(false)
    end

    it "should show error message if story has already removed from editor picks " do
        sign_in @content_mgr
        story = FactoryGirl.create(:story, title: "Editor_Story", :status => Story.statuses[:published], :editor_recommended => true)
        story_recomnd = FactoryGirl.create(:recommendation, recommendable_id: story.id, recommendable_type: "Story")
        Story.reindex
        post :remove_from_editor_picks, :id => story.id, format: :json
        expect_json(ok: true)
        expect_json_keys([:ok])
        post :remove_from_editor_picks, :id => story.id, format: :json
        expect_json_keys([:ok, :data])
        expect_json('data', "Story has already removed from editor picks")
        expect_status(200)
        expect(Story.first.editor_recommended).to eq(false)
    end

    it "should not be able to remove story from editors_pick if the current user is not content manager" do
      sign_in @user
      story = FactoryGirl.create(:story, title: "original_story", :status => Story.statuses[:published], :editor_recommended => true)
      Story.reindex
      post :remove_from_editor_picks, :id => story.id, format: :json
      expect_json_keys([:ok, :data])
      expect_json(ok: false)
      expect_json_keys("data", [:errorCode, :errorMessage])
      expect_status(401)
      expect_json('data.errorMessage', "You are not authorized to perform this action.")
    end
  end

  context "#smiley_ratings" do
    before(:each) do
      @story = FactoryGirl.create(:story)
      Story.reindex
      @smileycount = ->(story) {return SmileyRating.where(story: story).count }
      @smiley_count = @smileycount[@story]
      @smiley_ratings = {love: "love", okay: "okay"}
    end

    it "Should the update the smiley rating of the story for the logged in user" do
      user = FactoryGirl.create(:user)
      sign_in user
      params = {storySlug: @story.id, reaction: @smiley_ratings[:love]}
      post :smiley_ratings, params
      @updated_count = @smileycount[@story]
      expect(@updated_count).to eq @smiley_count+1
    end

    it "Should not update the smiley rating if the user already submmited the rating" do
      user = FactoryGirl.create(:user)
      sign_in user
      params = {storySlug: @story.id, reaction: @smiley_ratings[:okay]}
      post :smiley_ratings, params
      @updated_count = @smileycount[@story]
      post :smiley_ratings, params
      @most_updated_count = @smileycount[@story]
      expect(@updated_count).to eq @most_updated_count
    end

    it "Should update the smiley rating for every different user session" do
      user = FactoryGirl.create(:user)
      params = {storySlug: @story.id, reaction: @smiley_ratings[:okay]}
      post :smiley_ratings, params
      @updated_count = @smileycount[@story]
      sign_in user
      post(:smiley_ratings, params, {'id' => user.id})
      @most_updated_count = @smileycount[@story]
      expect(@most_updated_count).to eq @updated_count+1
    end

    it "Should not update the smiley rating if for non-logged user of same session" do
      params = {storySlug: @story.id, reaction: @smiley_ratings[:love]}
      post :smiley_ratings, params
      @updated_count = @smileycount[@story]
      expect(@updated_count).to eq @smiley_count+1
      post :smiley_ratings, params
      @most_updated_count = @smileycount[@story]
      expect(@most_updated_count).to eq @updated_count
    end
  end

end
