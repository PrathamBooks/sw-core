require 'rails_helper'

describe StoryEditorController, :type => :controller do
  before :each do
    @user= FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET story" do
    it "renders the story template with story" do
      story = create_sample_story(Story.statuses[:draft], @user)

      get :story, id: story.id

      expect(response).to have_http_status(200)
      expect(response).to be_success
      expect(response).to render_template("story")
      expect(assigns(:story)).to eq(story)
    end

=begin
    it "should assign illustrations" do
      story = create_sample_story
      illustrations = Search::Illustrations.search
      get :story, id: story.id
      expect(assigns(:illustrations)).to match_array(illustrations.results)
    end
=end

    it "should redirect user to signin page when he is not signed in" do
      sign_out :user
      story = create_sample_story

      get :story, id: story.id

      expect(response).to redirect_to(new_user_session_path)
    end

    describe "Authorisation" do
      before :each do
        sign_out :user
      end

      it "should not allow user who does not have to access to edit story" do
        story = create_sample_story(Story.statuses[:draft])
        sign_in FactoryGirl.create(:user)

        get :story, id: story.id

        # expect{get :story, id: story.id}.to raise_error(Pundit::NotAuthorizedError)
      end

      it "should allow author to edit a draft story" do
        story = create_sample_story(Story.statuses[:draft])
        sign_in story.authors.first

        get :story, id: story.id

        expect(response).to render_template("story")
      end

      it "should allow content manager to edit a draft story" do
        story = create_sample_story(Story.statuses[:draft])
        user = FactoryGirl.create(:content_manager)
        user.site_roles = "content_manager"
        user.save!
        sign_in user

        get :story, id: story.id

        expect(response).to render_template("story")
      end

      it "should allow publisher to edit a draft story" do
        @organization = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:user)
        user.organization = @organization
        user.organization_roles = "publisher"
        user.save!
        story = create_story_as_publisher.first
        story.organization = @organization
        story.save!
        sign_in user

        get :story, id: story.id

        expect(response).to render_template("story")
      end

      it "should not allow author to edit an uploaded story" do
        story = create_sample_story(Story.statuses[:uploaded])
        sign_in story.authors.first

        get :story, id: story.id

        #expect(response).to render_template("story")
      end

      it "should allow content manager to edit an uploaded story" do
        story = create_sample_story(Story.statuses[:uploaded])
        user = FactoryGirl.create(:content_manager)
        user.site_roles = "content_manager"
        user.save!
        sign_in user
        get :story, id: story.id

        expect(response).to render_template("story")
      end

      it "should allow publisher to edit an uploaded story" do
        @organization = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:user)
        user.organization = @organization
        user.organization_roles = "publisher"
        user.save!
        story = create_story_as_publisher(Story.statuses[:uploaded]).first
        sign_in user

        get :story, id: story.id

        expect(response).to render_template("story")
      end

      it "should allow reviewer to edit an uploaded story" do
        story = create_sample_story(Story.statuses[:uploaded])
        user = FactoryGirl.create(:user)
        story.editor = user
        story.save!
        sign_in story.editor

        get :story,id: story.id

        expect(response).to render_template("story")
      end

    end

  end

  describe "GET Illusration" do
    it "should return illustration details if successful" do
      page = FactoryGirl.create(:story_page)
      illustration = FactoryGirl.create(:illustration)
      # illustration_crop = illustration.process_crop!(page)
      get :illustration_for_crop, id: illustration.id, page_id: page.id
      expect(response).to be_success
      json_response = JSON.parse response.body
      expect(json_response['status']).to eq('success')
      expect(json_response['url']).to include(illustration.image.url(:original_for_web))
      expect(json_response['width']).to eq Paperclip::DUMMY_WIDTH.to_f
      expect(json_response['height']).to eq Paperclip::DUMMY_HEIGHT.to_f
    end
    it "should return error details if unsuccessful" do
      page = FactoryGirl.create(:story_page)
      get :illustration_for_crop, id: 'a', page_id: page.id
      expect(response).to_not be_success
      json_response = JSON.parse response.body
      expect(json_response).to eq({
        "status"=>"error",
        "message"=>"Illustration not found!"
      })
    end
  end

  describe "GET page_edit" do
    it "should return page template based on the id" do

      story,pages,template = create_story_with_pages
      xhr :get, :page_edit, id: pages.first.id, format: :js

      expect(response).to render_template("page_edit")
      expect(assigns(:page).page_template).to eql(template)
    end

    it "should return all templates based on story orientation" do
      story,pages,template = create_story_with_pages
      xhr :get, :page_edit, id: pages.first.id, format: :js
      templates = FrontCoverPageTemplate.of_orientation(pages.first.page_template.orientation)
      expect(templates).not_to be_nil
      expect(assigns(:template_options)).not_to be_nil
      expect(assigns(:template_options)).to match_array(templates)
    end
  end
  describe "PUT change_page_template " do
    it "render with new template" do
      story,pages,template = create_story_with_pages
      new_template= FactoryGirl.create(:front_cover_page_template, orientation: "landscape")
      xhr :put, :change_page_template, {page_id: pages.first.id, id: new_template.id}, format: :js
      expect(assigns(:page).page_template).to eq(new_template)
    end

    it "should update Front Cover , Back Cover and Back inne cover page template when changing the orientation" do
      new_portrait_template= FactoryGirl.create(:front_cover_page_template_portrait)
      FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'portrait')
      FactoryGirl.create(:back_cover_page_template, default: true, orientation: 'portrait')
      story,pages,template = create_story_with_pages
      xhr :put, :change_page_template, {page_id: pages.first.id, id: new_portrait_template.id}, format: :js
      expect(assigns(:page).page_template).to eq(new_portrait_template)
      expect(assigns(:story).page_orientation).to eq('portrait')
      expect(assigns(:story).pages.last.page_template.orientation).to eq('portrait')
      expect(assigns(:story).pages[-2].page_template.orientation).to eq('portrait')
    end
  end

  describe "POST update_page_content" do
    it "should updated page's content" do
      story,pages,template = create_story_with_pages
      xhr :post, :update_page_content, {id: pages[1].id,page: {content: 'hello content'}}, format: :js
      expect(assigns(:page).content).to eql('hello content')
    end
  end

  describe "POST auto_save_content" do
    it "should updated page's content" do
      story, pages, template = create_story_with_pages
      xhr :post, :auto_save_content, {id: pages[1].id,page: {content: 'hello content'}}, format: :js
      expect(assigns(:page).content).to eql('hello content')
      expect(response).to render_template("auto_save_content")
    end
  end

  describe "POST update_page_illustration" do
     it "should delete the existing illustration crop object and should render crop overlay" do
      story,pages,template = create_story_with_pages
      illustration = FactoryGirl.create(:illustration)

      xhr :post, :update_page_illustration, {id: pages[1].id,page: {illustration_id: illustration.id}}, format: :js
      expect(assigns(:page).illustration_crop.present?).to eql(false)
      expect(response).to render_template("update_page_illustration")
    end
  end

  describe "PUT insert_new_page" do
    it "render with new page" do
      story,pages,template = create_story_with_pages
      page_count = pages.size
      xhr :put, :insert_page, {story_id: story.id,id: pages.first.id, number_of_pages: 1}, format: :js
      expect(assigns(:story).pages.count).to eq(page_count + 1)
    end
  end

  describe "PUT duplicate_a_new_page" do
    it "render with duplicated page" do
      story,pages,template = create_story_with_pages
      page_count = pages.size
      page = pages.second
      xhr :put, :duplicate_page, {id: page.id,story_id: story.id}, format: :js
      expect(assigns(:page).attributes.slice!("id","position","created_at","updated_at")).to eq(page.attributes.slice!("id","position","created_at","updated_at"))
    end
  end

  describe "DELETE page from story" do
    it "render with previous page" do
      story,pages,template = create_story_with_multiple_pages
      page_count = pages.size
      story_page_1 = story.pages.second
      story_page_2 = story.pages.third
      xhr :delete, :delete_page, {id: story_page_1.id, story_id: story.id}, format: :js
      expect(assigns(:story).pages.count).to eq(page_count - 1)
      expect(assigns(:page).position).to eq(story_page_1.higher_item.position)
    end
  end

  describe "POST re arrange a page position" do
    it "render with re arranged page" do
      story,pages,template = create_story_with_multiple_pages
      page_count = pages.size
      story_page_1 = story.pages.second
      story_page_2 = story.pages.third
      story_page_3 = story.pages.fourth
      xhr :post, :rearrange_page, {id: story.id, page: { page_id: story_page_3.id, position: story_page_1.position}}, format: :js
      expect(assigns(:page)).to eq(story_page_3)
      expect(assigns(:page).position).to eq(story_page_1.position)
    end
  end

  describe "GET validate story pages" do
    it "renders validate story pages template and assign errors" do
      story,pages,template = create_story_with_errors_in_pages

      xhr :get, :validate_story_pages, {id: story.id}, format: :js

      expect(response).to be_success
      expect(response).to render_template("validate_story_pages")
      expect(assigns(:image_errors)).to match_array([1, 2, 4])
      expect(assigns(:orientation_errors)).to match_array([4, 5])
    end
  end

  describe "GET publish_form" do
    it "renders publish form" do
      story,pages,template = create_story_with_pages

      xhr :get, :publish_form, {id: story.id}, format: :js

      expect(response).to be_success
      expect(response).to render_template("publish_form")
      expect(assigns(:story)).to eql(story)
    end
  end

  describe "PATCH publish" do
    it "updates and publishes story when there are no errors" do
      story,pages,template = create_story_with_pages(Story.statuses[:draft])
      new_category = FactoryGirl.create(:story_category)
      
      xhr :patch, :publish,
        {id: story.id,
         story: {title: 'updated_title',
                 english_title: 'updated english title',
                 synopsis: 'updated_synopsis',
                 reading_level: '2',
                 category_ids: [new_category.id],
                 copy_right_holder_id: ""

      }}, format: :js

      story.reload
      expect(response).to be_success
      expect(response).to render_template('publish')
      expect(story.title).to eql('updated_title')
      expect(story.english_title).to eql('updated english title')
      expect(story.synopsis).to eql('updated_synopsis')
      expect(story.reading_level).to eql('2')
      expect(story.status).to eql('publish_pending')
      expect(story.categories.collect(&:id)).to eql([new_category.id])
    end

    describe "publisher login" do
      before :each do
        sign_out @user
        @organization = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:user)
        user.organization = @organization
        user.organization_roles = "publisher"
        user.save!
        sign_in user
      end

      it "updates authors and publishes story for a publisher login" do
        story,pages,template = create_story_as_publisher
        new_author = FactoryGirl.create(:user)

        xhr :patch, :publish,
          {id: story.id,
           :story =>{
            :title => 'updated_title',
            copy_right_holder_id: "",
            :authors_attributes =>{
              0 =>{
                email: new_author.email,
                first_name: new_author.first_name,
                last_name: new_author.last_name,
                id: new_author.id
              }
            }
          }
        }, format: :js

        story.reload
        expect(response).to be_success
        expect(response).to render_template('publish')
        expect(story.title).to eql('updated_title')
        expect(story.status).to eql('publish_pending')
        expect(story.authors).to match_array([new_author])
      end

      it "creates accounts for authors when they do not exist and publishes story for a publisher login" do
        story,pages,template = create_story_as_publisher
        author_email = "new_user_#{Time.now.to_i}@sample.com"
        author_first_name = "new_user_first_name"
        author_last_name = "new_user_last_name"

        xhr :patch, :publish,
          {id: story.id,
           :story =>{
            :title => 'updated_title',
            copy_right_holder_id: "",
            :authors_attributes =>{
              0 =>{
                email: author_email,
                first_name: author_first_name,
                last_name: author_last_name,
                id: 1
              }
            }
          }
        }, format: :js

        story.reload
        expect(response).to be_success
        expect(response).to render_template('publish')
        expect(story.status).to eql('publish_pending')
        expect(story.authors.length).to eql(1)
        expect(story.authors.first.email).to eql(author_email)
        expect(story.authors.first.first_name).to eql(author_first_name)
        expect(story.authors.first.last_name).to eql(author_last_name)
      end

      it "renders publish form when there are errors for a publisher login" do
        story,pages,template = create_story_as_publisher
        author_email = "new_user_#{Time.now.to_i}@sample.com"
        original_title = story.title

        xhr :patch, :publish,
          {id: story.id,
           :story =>{
            :title => 'updated_title',
            copy_right_holder_id: "",
            :authors_attributes =>{
              0 =>{
                email: author_email,
                first_name: '',
                last_name: '',
                id: 1
              }
            }
          }
        }, format: :js

        story.reload
        expect(response).to be_success
        expect(response).to render_template('publish_form')
        expect(story.title).to eql(original_title)
        expect(story.status).to eql('draft')
      end
    end

    it "renders publish form when there are errors" do
      story,pages,template = create_story_with_pages(Story.statuses[:draft])
      original_title = story.title

      xhr :patch, :publish,
        {id: story.id, story: {title: '',copy_right_holder_id: ""}}, format: :js

      story.reload
      expect(response).to be_success
      expect(response).to render_template('publish_form')
      expect(story.title).to eql(original_title)
      expect(story.status).to eql('draft')
    end
  end

  def create_story_with_pages(status = Story.statuses[:published])
    cover_page_template= FactoryGirl.create(:front_cover_page_template_2)
    FactoryGirl.create(:front_cover_page_template, orientation: "landscape")
    FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
    FactoryGirl.create(:back_cover_page_template, default: true, orientation: 'landscape')
      story = FactoryGirl.create(:story, status: status, authors: [@user])
      story.build_book  cover_page_template
      story_page = FactoryGirl.create(:story_page)
      story.insert_page(story_page)
      story.save
      [story,story.pages,story.pages.first.page_template]
  end

  def create_story_with_multiple_pages
    cover_page_template= FactoryGirl.create(:front_cover_page_template_2)
    FactoryGirl.create(:front_cover_page_template, orientation: "landscape")
    FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
    FactoryGirl.create(:back_cover_page_template, default: true, orientation: 'landscape')
      story = FactoryGirl.create(:story)
      story.build_book  cover_page_template
      story_page_1 = FactoryGirl.create(:story_page)
      story_page_2 = FactoryGirl.create(:story_page)
      story.insert_page(story_page_1)
      story.insert_page(story_page_2)
      story.save
      [story,story.pages,story.pages.first.page_template]
  end

  def create_story_with_errors_in_pages
    cover_page_template= FactoryGirl.create(:front_cover_page_template_2)
    FactoryGirl.create(:front_cover_page_template, orientation: "landscape")
    FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
    FactoryGirl.create(:back_cover_page_template, default: true, orientation: 'landscape')
      story = FactoryGirl.create(:story)
      story.build_book  cover_page_template
      story_page_1 = FactoryGirl.create(:story_page)
      story_page_2 = FactoryGirl.create(:story_page)
      story_page_3 = FactoryGirl.create(:story_page, page_template: FactoryGirl.create(:story_page_template, orientation: 'portrait'))
      story_page_3 = FactoryGirl.create(:story_page, page_template: FactoryGirl.create(:story_page_template, orientation: 'portrait'))
      story_page_4 = FactoryGirl.create(:story_page, page_template: FactoryGirl.create(:story_page_template, orientation: 'portrait'))
      story.insert_page(story_page_1)
      story.insert_page(story_page_2)
      story.insert_page(story_page_3)
      story.insert_page(story_page_4)
      generate_illustration_crop(story_page_2)
      generate_illustration_crop(story_page_4)
      story.save
      [story,story.pages,story.pages.first.page_template]
  end

  def create_sample_story(status = Story.statuses[:published], author = FactoryGirl.create(:user))
    FactoryGirl.create(:front_cover_page_template, orientation: "portrait")
    FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
    FactoryGirl.create(:back_cover_page_template, default: true, orientation: 'landscape')
      story = FactoryGirl.create(:story, status: status, authors: [author])
      story.build_book
      story_page = FactoryGirl.create(:story_page)
      story.insert_page(story_page)
      story.save
      story
  end

  def create_story_as_publisher(status = Story.statuses[:draft])
    cover_page_template= FactoryGirl.create(:front_cover_page_template_2)
    FactoryGirl.create(:front_cover_page_template, orientation: "landscape")
    FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
    FactoryGirl.create(:back_cover_page_template, default: true, orientation: 'landscape')
      story = FactoryGirl.create(:story, status: status, organization: @organization, authors: [])
      story.build_book  cover_page_template
      story_page = FactoryGirl.create(:story_page)
      story.insert_page(story_page)
      story.save
      [story,story.pages,story.pages.first.page_template]
  end
end
