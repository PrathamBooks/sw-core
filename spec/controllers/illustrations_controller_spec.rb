require 'rails_helper'

describe IllustrationsController, :type => :controller do

  describe "GET index" do
    it "responds successfully with an HTTP 200 status code" do
      Illustration.reindex
      #get :index

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the index template" do
      Illustration.reindex

      #get :index

      #expect(response).to render_template("index")
    end

    describe "search" do
        it "should show all illustrations when no query is specified" do
          i1, i2 = FactoryGirl.create(:illustration),FactoryGirl.create(:illustration)
          Illustration.reindex

          #get :index

          #expect(assigns(:results).collect(&:name).include?(i1.name)).to be true
          #expect(assigns(:results).collect(&:name).include?(i2.name)).to be true
        end

        it "should search by name" do
          i1 = FactoryGirl.create(:illustration, name: 'My school ' + SecureRandom.uuid, updated_at: DateTime.yesterday.to_datetime)
          i2 = FactoryGirl.create(:illustration, name: 'my home ' + SecureRandom.uuid, updated_at: DateTime.now.to_datetime)
          Illustration.reindex

          #get :index

          search_params = {query: "my", categories: [], styles: [],license_types: []}
          get :index, search: search_params

          expect(assigns(:results).collect(&:name).include?(i1.name)).to be true
          expect(assigns(:results).collect(&:illustrators).flatten.include?(i1.illustrator_name)).to be true
          expect(assigns(:results).collect(&:name).include?(i2.name)).to be true
          expect(assigns(:results).collect(&:illustrators).flatten.include?(i2.illustrator_name)).to be true
          expect(assigns(:results).find_index{|result| result.name.include?('my home')} < assigns(:results).find_index{|result| result.name.include?('My school')} ).to be true
        end

         it "should filter by categories" do
          category1 = FactoryGirl.create(:illustration_category)
          category2 = FactoryGirl.create(:illustration_category)
          i1 = FactoryGirl.create(:illustration, name: 'Name 1' + SecureRandom.uuid,categories: [category1])
          i2 = FactoryGirl.create(:illustration, name: 'Name 2' + SecureRandom.uuid,categories: [category2])
          Illustration.reindex

          search_params = {query: "Name", categories: [category1.name, ''], styles: [],license_types: [], image_mode: 'false', is_publisher_cm: 'false', content_manager: 'false'}
          get :index, search: search_params

          expect(assigns(:results).collect(&:name).include?(i1.name)).to be true
          expect(assigns(:results).collect(&:name).include?(i2.name)).to be false
          expect(assigns(:search_params)).to eql({'query'=>'Name', 'categories'=>[category1.name], 'styles' => [],'license_types' => [], 'illustrators' => nil, 'organization' => nil, "image_mode" => "false", "editor_fav_images"=>nil, "favorites_of_story"=>nil, "illustrator_slugs" => nil, "is_organization_cm"=>false, "content_manager"=>nil, "tags" => nil})
          expect(assigns(:filters)).to eql({categories: [category1.name], image_mode: "false", is_pulled_down: false})
        end

         it "should filter by styles" do
          style1 = FactoryGirl.create(:style)
          style2 = FactoryGirl.create(:style)
          i1 = FactoryGirl.create(:illustration, name: 'Name 1' + SecureRandom.uuid,styles: [style1])
          i2 = FactoryGirl.create(:illustration, name: 'Name 2' + SecureRandom.uuid,styles: [style2])

          Illustration.reindex

          search_params = {query: "Name", categories: [], styles: [style1.name,''],license_types: [],image_mode: 'false', is_organization_cm: 'false', content_manager: 'false'}
          get :index, search: search_params

          expect(assigns(:results).collect(&:name).include?(i1.name)).to be true
          expect(assigns(:results).collect(&:name).include?(i2.name)).to be false
          expect(assigns(:search_params)).to eql({'query'=>'Name', 'categories'=>[], 'styles' => [style1.name],'license_types' => [], 'illustrators' => nil, 'organization' => nil, 'image_mode' => "false", "editor_fav_images"=>nil, "favorites_of_story"=>nil, "illustrator_slugs" => nil, "is_organization_cm"=>false, "content_manager"=>nil, "tags" => nil})
          expect(assigns(:filters)).to eql({styles: [style1.name],image_mode: "false", is_pulled_down: false})
         end
# license type filter not availabe on system
=begin
         it "should filter by license type" do

          i1 = FactoryGirl.create(:illustration, name: 'Name 1' + SecureRandom.uuid,license_type: 'CC BY 0')
          i2 = FactoryGirl.create(:illustration, name: 'Name 2' + SecureRandom.uuid,license_type: 'CC BY 4.0')

          Illustration.reindex

          search_params = {query: "Name", categories: [], styles: [],license_types: ['CC BY 0',''],image_mode: 'false', is_publisher_cm: 'false', content_manager: 'false'}
          get :index, search: search_params

          expect(assigns(:results).collect(&:name).include?(i1.name)).to be true
          expect(assigns(:results).collect(&:name).include?(i2.name)).to be false
          expect(assigns(:search_params)).to eql({'query'=>'Name', 'categories'=>[], 'styles' => [],'license_types' => ['CC BY 0'], 'contest_id' => nil,'illustrators' => nil, 'publisher' => nil, 'image_mode' => "false", "is_publisher" => false, "editor_fav_images"=>nil, "favorites_of_story"=>nil})
          expect(assigns(:filters)).to eql({license_type: ['CC BY 0'],image_mode: "false", is_pulled_down: false})
        end
=end

         it "should search by tag" do
          i1 = FactoryGirl.create(:illustration, name: 'My school ' + SecureRandom.uuid, tag_list: "anime")
          i2 = FactoryGirl.create(:illustration, name: 'my home ' + SecureRandom.uuid, tag_list: "cartoon")
          Illustration.reindex


          search_params = {query: "cartoon", categories: [], styles: [],license_types: []}
          get :index, search: search_params

          expect(assigns(:results).collect(&:name).include?(i1.name)).to be false
          expect(assigns(:results).collect(&:name).include?(i2.name)).to be true
        end
    end
  end

  describe "GET new" do
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user
    end

    it "renders the new template" do
      get :new

      expect(response).to render_template("new")
    end

    it "load new illustration object as @illustration" do
      get :new
      expect(assigns(:illustration).new_record?).to eql(true)
    end
  end

  describe "Illustration download count reset" do
    it "POST - should reset the illustration download count for user" do
      @user = FactoryGirl.create(:user, :illustration_download_count => 40)
      post :reset_illustration_download_count, :email => @user.email
      user = User.find_by_email(@user.email)
      expect(response.status).to eql(200)
      #expect(user.illustration_download_count).to eql 0
    end
  end

  describe "POST create" do
    let(:random_email) { (0...20).map { ('a'..'z').to_a[rand(26)] }.join+"@b.com" }
    let(:style) { FactoryGirl.create(:style) }
    let(:c1) { FactoryGirl.create(:illustration_category) }
    let(:c2) { FactoryGirl.create(:illustration_category) }
    let(:attributes) do
      attributes = FactoryGirl.attributes_for(:illustration)
      attributes.merge!({style_ids: [style.id], category_ids:[c1.id,c2.id]})
      attributes.merge!({license_type: 'CC BY 4.0'})
      attributes.merge!({image:  Rack::Test::UploadedFile.new('spec/photos/forest.jpg', 'image/jpg')})
      attributes
    end

    before :each do
      @content_manager= FactoryGirl.create(:content_manager)
      @user= FactoryGirl.create(:user)
      sign_in @user
    end

    it "should redirect to index with a notice on successful save" do
      post :create, illustration: attributes
      expect(assigns(:illustration).illustrator_name).to eql(@user.name)
      expect(assigns(:illustration).categories).to match_array([c1,c2])
      expect(response).to render_template(:index)
    end

    it "should re-render new template on failed save" do
      post :create, illustration: {name: ""}
      expect(assigns(:illustration).valid?).to eql(false)
      expect(flash[:notice].blank?).to eql(true)
      expect(response).to render_template(:new)
    end

    it "should assign an uploader" do
      post :create, illustration: attributes
      illustration = assigns(:illustration)
      expect(illustration.uploader).to eql(@user)
    end

    describe "when uploader is not a publisher" do
      it "should assign uploader as illustrator if illustrator name matches" do
        expect(@user.has_role?(:publisher)).to be false
        post :create, illustration: attributes
        illustration = assigns(:illustration)
        expect(illustration.illustrators.first.user).to eql(@user)
        expect(illustration.uploader).to eql(@user)
      end
    end
      
    describe "when uploader is a publisher" do
      before(:each) do
        @organization = FactoryGirl.create(:organization)
        @user = FactoryGirl.create(:user)
        @user.organization = @organization
        @user.organization_roles = "publisher"
        @user.logo = Rack::Test::UploadedFile.new('spec/photos/logo.png', 'image/png')
        @user.save!
        sign_in @user

      end
      it "should not create if illustrator name is not provided" do
        illustrator_name = @user.name+'DJ'
        attributes.merge!(illustrators_attributes: {0 => {:email => random_email, :first_name => '', :last_name => '' }})
        post :create, illustration: attributes
        expect(response).to render_template(:new)
      end
      it "should not create if illustrator email is not provided" do
        illustrator_name = @user.name+'DJ'
        attributes.merge!(illustrator_name: illustrator_name)
        attributes.merge!(illustrator_email: "")
        post :create, illustration: attributes
        expect(response).to render_template(:new)
      end
      it "should create an illustrator account if not present" do
        illustrators_email = random_email
        illustrator_first_name = @user.first_name+'DJ'
        illustrator_last_name = @user.last_name
        attributes.merge!(illustrators_attributes: {0 => {:email => illustrators_email, :first_name => illustrator_first_name, :last_name => illustrator_last_name }})
        expect(User.find_by_email(illustrators_email)).to be_nil
        post :create, illustration: attributes
        expect(User.find_by_email(illustrators_email)).to_not be_nil
      end
      it "should set the illustrator's bio" do
        illustrators_email = random_email
        illustrator_first_name = @user.first_name+'DJ'
        illustrator_last_name = @user.last_name
        illustrator_bio = "I never went to school."
        attributes.merge!(illustrators_attributes: {0 => {:email => illustrators_email, :first_name => illustrator_first_name, :last_name => illustrator_last_name , :bio => illustrator_bio}})
        post :create, illustration: attributes
        user = User.find_by_email(illustrators_email)
        expect(user.bio).to eql(illustrator_bio)
      end
      it "should link an illustrator account if present" do
        illustrator = FactoryGirl.create(:user)
        illustrators_email = illustrator.email
        illustrator_first_name = illustrator.first_name
        illustrator_last_name = illustrator.last_name
        attributes.merge!(illustrators_attributes: {0 => {:email => illustrators_email, :first_name => illustrator_first_name, :last_name => illustrator_last_name}})
        expect(User.find_by_email(illustrators_email)).to_not be nil
        user_count = User.count
        post :create, illustration: attributes
        illustration = assigns(:illustration)
        expect(User.count).to eql(user_count)
        expect(illustration.illustrators.first.user).to eql(illustrator)
      end
      it "should create a new person account if creating an illustrator user" do
        illustrators_email = random_email
        illustrator_first_name = @user.first_name+'DJ'
        illustrator_last_name = @user.last_name
        attributes.merge!(illustrators_attributes: {0 => {:email => illustrators_email, :first_name => illustrator_first_name, :last_name => illustrator_last_name}})
        expect(User.find_by_email(illustrators_email)).to be nil
        expect(Person.find_by_first_name_and_last_name(illustrator_first_name,illustrator_last_name)).to be nil
        FactoryGirl.create(:person,first_name: illustrator_first_name,last_name: illustrator_last_name)
        expect(Person.where({first_name: illustrator_first_name,last_name: illustrator_last_name}).count).to eql(1)
        post :create, illustration: attributes
        expect(User.find_by_email(illustrators_email)).to_not be nil
        expect(Person.where({first_name: illustrator_first_name,last_name: illustrator_last_name}).count).to eql(2)
      end
      it "should not create a new person account if illustrator user is linked" do
        illustrators_email = random_email
        illustrator_first_name = @user.first_name+'DJ'
        illustrator_last_name = @user.last_name
        attributes.merge!(illustrators_attributes: {0 => {:email => illustrators_email, :first_name => illustrator_first_name, :last_name => illustrator_last_name}})
        person = FactoryGirl.create(:person,first_name: illustrator_first_name,last_name: illustrator_last_name)
        user = FactoryGirl.create(:user,first_name: illustrator_first_name,last_name: illustrator_last_name , email: random_email)
        person.user = user
        expect(person.save).to be true
        expect(Person.where({first_name: illustrator_first_name,last_name: illustrator_last_name}).count).to eql(1)
        expect(User.where({email: illustrators_email}).count).to eql(1)
        post :create, illustration: attributes
        expect(Person.where({first_name: illustrator_first_name,last_name: illustrator_last_name}).count).to eql(1)
        expect(User.where({email: illustrators_email}).count).to eql(1)
      end
    end
  end

  describe "PUT update" do
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user
      @illustration = FactoryGirl.create(:illustration)
    end

    it "should redirect to index with a notice on successful update" do
      attributes = @illustration.attributes
      attributes.merge!({license_type: 'CC BY 4.0'})
      attributes["name"]="Update"
      patch :update,id: @illustration.id, illustration: attributes
      expect(assigns(:illustration).persisted?).to eql(true)
      expect(assigns(:illustration).name).to eql("Update")
      expect(response).to redirect_to(illustrations_path)
    end

    it "should re-render edit template on failed save" do
      attributes = @illustration.attributes
      attributes.merge!({license_type: 'CC BY 4.0'})
      attributes["name"]=""
      patch :update,id: @illustration.id, illustration: attributes
      expect(assigns(:illustration).valid?).to eql(false)
      expect(response).to render_template(:edit)
    end
  end

  describe "GET show" do
    before :each do
      @user= FactoryGirl.create(:user)
      sign_in @user
      @illustration = FactoryGirl.create(:illustration)
    end

    it "renders the show template" do
      get :show,id: @illustration.id
      expect(response).to render_template("show")
      expect(assigns(:illustration).name).to eql(@illustration.name)
    end

    it "should fetch all the similar illstrations" do

      person = Person.create(first_name: @user.first_name, last_name: @user.last_name)

      category_1 = FactoryGirl.create(:illustration_category, name: "Nature & Weather")
      category_2 = FactoryGirl.create(:illustration_category, name: "Animals & Birds")

      @illustration_1 = FactoryGirl.create(:illustration,  name: "illustration 1", categories: [category_1,category_2], illustrators: [person] )

      @illustration_2 = FactoryGirl.create(:illustration,  name: "illustration 2", categories: [category_1], illustrators: [person])
            
      @illustration_3 = FactoryGirl.create(:illustration, name: "illustration 3", categories: [category_2], illustrators: [person])
      
      Illustration.reindex

      get :show,id: @illustration_1.id

      expected_names = [@illustration_2,@illustration_3].map(&:name)
      expect(assigns(:similar_illustrations).collect(&:name)).to match_array(expected_names)
    end
  end

  describe "User Authentication" do
    it "GET new - redirects to sign_in page when user is not signed in" do
      get :new

      expect(response).to redirect_to(new_user_session_path)
    end

     it "POST create - redirects to sign_in page when user is not signed in" do
      post :create, illustration: {}

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET flagging a illustration" do
    before(:each) do
      @content_manager= FactoryGirl.create(:content_manager)
      @user = FactoryGirl.create(:user)
      @illustration = FactoryGirl.create(:illustration)
      sign_in @user
    end

    it "should force the user to sign in before flagging a story" do
      sign_out @user
      attributes = {id: @illustration.id, reasons: 'reason for flagging'}

      xhr :post, :flag_illustration, attributes

      expect(response.status).to eql(401)
    end

    it "should allow the user to flag a illustration" do
      attributes = {id: @illustration.id, reasons: 'reason for flagging'}

      xhr :post, :flag_illustration, attributes

      @illustration.reload
      expect(response).to render_template("flag_illustration")
      expect(@user.flagged?(@illustration, 'reason for flagging')).to be true
    end
 
    it "should not do anything when the user flags the same story more than once" do
      attributes =  {id: @illustration.id, reasons: 'reason for flagging'}

      xhr :post, :flag_illustration, attributes
      xhr :post, :flag_illustration, attributes

      @illustration.reload
      expect(response).to render_template("new_flag_illustration")
      expect(@user.flagged?(@illustration, 'reason for flagging')).to be true
    end
  end

end
