class IllustrationsController < ApplicationController
  autocomplete :user, :email, :full => true, :extra_data => [:email,:bio,:first_name,:last_name]
  autocomplete :tag, :name, :class_name => 'ActsAsTaggableOn::Tag'

  before_action :authenticate_user!,  only: [:flag_illustration]
  
  before_action only: [:new, :create, :download] do
    store_location_and_redirect(illustrations_path,new_user_session_path)
  end

  def index
    @menu = "illustrations"
    @illustration_search = true
    @contest = Contest.find(params[:contest_id]) unless params[:contest_id].nil?
    @story = Story.find(params[:story_id]) unless params[:story_id].nil?
    @search_query = params[:search][:query] unless params[:search].blank?
    @categories = IllustrationCategory.all
    params[:current_user] = current_user ? current_user.id : 0 
    params[:is_organization_cm] = current_user && (current_user.organization? || current_user.content_manager?) ? true : false
    params[:illustrator_name] = current_user ? current_user.name : nil
    session[:start_with_images] = false
    if (params[:editor_fav_images]== "false" && params[:search] && params[:search][:query] == "")
      s = Search::EditorIllustrations.search(params)
      @results = s.results
      @search_params = params[:search]
      results = @results      
    else
      s = Search::Illustrations.search(params)
      @results =  s.results
      @search_params = s.params
      @filters = s.filters
      check_query = true if @search_params[:query].blank? && @search_params[:sort].blank? && @search_params[:organization].blank? && @search_params[:categories].blank? && @search_params[:styles].blank?
      results = check_query == true ? s.random_results : @results
    end
    respond_to do |format|
      format.html
      format.json { render :json => {
        query: @search_params,
          # order: order_criteria,
          search_results: results.map { |result| sanitize_search_results_for_api(result) },
          metadata: {
            hits:         @results.total_count,
            per_page:     @results.per_page,
            page:         @results.current_page,
            total_pages:  @results.total_pages
          }
        }
      }
    end
  end

  def new
    @illustration = Illustration.new
    @illustration.illustrators.build
    @contest = Contest.find(params[:contest_id]) unless params[:contest_id].nil?
    if @contest.present?
      @illustration.tag_list = "," + @contest.tag_name if @contest.tag_name.present?
    end
    respond_to do |format|
       format.html{}
       format.js
    end
  end

  def create
    @contest = Contest.find(params[:contest_id]) unless params[:contest_id].nil?
    if @contest.present? && @contest.contest_type == "illustration" && @contest.is_campaign == false
      params[:illustration][:tag_list] = params[:illustration][:tag_list] + "," + @contest.tag_name 
    end
    @story_id = params[:story_id] if params[:story_id].present?
    @story = Story.find(params[:illustration][:story_id].to_i) if params[:illustration][:story_id]
    @illustration = Illustration.new(illustration_params)
    @upload_from_editor = params[:illustration][:upload_from_editor] if params[:illustration][:upload_from_editor]
    respond_to do |format|
      if @illustration.set_illustrator(params[:illustration],current_user)
        @illustration.set_copyright(params[:illustration],current_user)
        @illustration.favorites << @story if @story && !@illustration.favorites.find_by_id(@story)
        @illustration.reindex
        content_managers=User.content_manager.collect(&:email).join(",")
        if @contest.present? && @contest.contest_type == "illustration" && @contest.is_campaign == false
          @contest.illustrations << @illustration
        else
          UserMailer.delay(:queue=>"mailer").uploaded_illustration(content_managers,@illustration) unless @illustration.organization.present?
        end
        flash.clear
        format.html{
          render :action => "index"
        }
        format.js{
          if @contest.present? && @contest.contest_type == "illustration" && @contest.is_campaign == false && @contest.custom_flash_notice.present?
            flash[:notice] = @contest.custom_flash_notice
          else
            flash[:notice] = "Your illustration is uploaded successfully. It will appear in search once processed!" unless @upload_from_editor
          end
        }
      else
        if @upload_from_editor == "true"
          puts @illustration.errors.full_messages.join(", ")
          flash.now[:error]=@illustration.errors.full_messages.join(", ")
          format.js { render 'story_editor/upload_illustration' }
        else
          puts @illustration.errors.full_messages.join(", ")
          flash.now[:error]=@illustration.errors.full_messages.join(", ")
          format.html{ render "new" }
          format.js
        end

      end
    end
  end

  def update
    @illustration = Illustration.find(params[:id])
    if @illustration.update_attributes(illustration_params)
      redirect_to illustrations_path
    else
      render :edit
    end
  end

  def show
    @illustration_search = true
    @illustration = Illustration.eager_load(:illustrators,:styles, :categories).find(params[:id])
    @similar_illustrations = @illustration.similar(fields: [:illustrators , :categories], where: {illustrators: @illustration.illustrators.map(&:name), categories: @illustration.categories.map(&:name)}, limit: 12, order: {_score: :desc}, operator: "and", load: false).results if @illustration rescue []
    respond_to do |format|
      format.html{
        if @illustration.is_pulled_down && (current_user ? current_user.get_pulled_down_access(@illustration) : true)
         redirect_to illustrations_path
         flash[:error] = "You are not authorized to perform this action."
        end
      }
      format.json do
        render json: {
          illustration: {
            name: @illustration.name,
            illustrators: @illustration.illustrator_first_name,
            uploader: @illustration.uploader.name,
            image_content_type: @illustration.image_content_type,
            image_file_size: @illustration.image_file_size,
            created_at: @illustration.created_at,
            attribution_text: @illustration.attribution_text,
            license_type: @illustration.license_type
          },
          links: [
            {
              rel: 'self',
              uri: illustration_path(@illustration)
            },
            {
              rel: 'original',
              uri: @illustration.image.url(:original)
            }
          ]
        }
      end
    end
  end

  def illustration_view
    @illustration = Illustration.eager_load(:illustrators,:styles, :categories).find(params[:id])
    respond_to do |format|
      format.html{redirect_to illustration_path(@illustration, :illus_view => true)}
      format.js
    end
  end

  def contest_image
    @contest = Contest.find_by_id(params[:contest_id])
    @illustration = Illustration.find_by_id(params[:illustration_id])
    @contest_image = @contest.illustrations.find_by_id(@illustration)
    if @contest_image
      @contest.illustrations.delete(@contest_image)
      @illustration.reindex
    else
      @contest.illustrations << @illustration
      @illustration.reindex
    end

    respond_to do |format|
        format.json { head :no_content }
    end
  end

  def download
    @illustration = Illustration.find_by_id(params[:id])
    current_user.update_attribute(:illustration_download_count, (current_user.illustration_download_count + 1))
    download_file(@illustration,params[:style].to_sym)
    @illustration.update_downloads(current_user, request.remote_ip, params[:style])
  end

  # /v0/illustrations/reset_illustration_download_count
  def reset_illustration_download_count
    current_user = User.find_by_email(params[:email])
    current_user.update_attribute(:illustration_download_count, (current_user.illustration_download_count + 1))
    current_user.save!
    render json: {"ok"=>true}
  end

  def new_flag_illustration
    @illustration = Illustration.find_by_id(params[:id])
    @flag = MakeFlaggable::Flagging.new
  end

  def flag_illustration
    @illustration = Illustration.find_by_id(params[:id])
    user = current_user
    @errors = []
    if user.flagged?(@illustration)
      @errors << "you have alreay flagged this illustration"
      render :new_flag_illustration
    else
      if !params[:reasons].blank?
        user.flag(@illustration, params[:reasons])
        content_managers=User.content_manager.collect(&:email).join(",")
        reason = params[:reasons]
        UserMailer.delay(:queue=>"mailer").flagged_illustration(content_managers,@illustration,user,reason)
      else
        @errors << "Reason can't be blank"
        render :new_flag_illustration
      end
    end
  end

  def illustration_used_in_stories 
    @illustration = Illustration.find_by_id(params[:id]) if params[:id].present?
    @stories =  @illustration.all_story_links
  end

  def edit_tags
    @illustration = Illustration.find(params[:id])
  end

  def update_tags
    @illustration = Illustration.find(params[:id])
    if @illustration
      @illustration.tag_list = params[:illustration][:tag_list]
      @illustration.save
    end
  end

  def update_favorites
    @illustrations = Search::Illustrations.search(size: 12).results
    @categories = IllustrationCategory.all
    @styles = IllustrationStyle.all
    @organizations = Organization.all
    illustration = Illustration.find(params[:illustration_id])
    @story = Story.find(params[:story_id])
    if illustration.favorites.find_by_id(@story)
      illustration.favorites.delete(@story)
      @remove_from_favorites = true
      illustration.reindex
    else
      illustration.favorites << @story
      illustration.reindex
    end
    respond_to do |format|
      format.js { head :no_content }
    end
  end

  private
  def illustration_params
    params.require(:illustration).permit(
      :name,
      :image,
      :crop_x,
      :crop_y,
      :crop_w,
      :crop_h,
      :selected_style,
      :attribution_text,
      :image_mode,
      :tag_list,
      :license_type,
      :sort,
      :copy_right_year,
      :copy_right_holder_id,
      category_ids: [],
      style_ids: [],
      child_illustrators_attributes:[:id, :name, :age, :_destroy]
      )
  end

  def sanitize_search_results_for_api(result)
    params[:contest_id] = nil
    sanitized_response = {}
    [
      "id","name","illustrators","illustrator_slugs","uploader","image_url", "likes", "liked_users", "reads", "publisher", "publisher_slug", "organization"
    ].each do |key|
      sanitized_response[key] = result[key]
    end
    sanitized_response[:links]=[
      :self => {
        rel: 'self',
        uri: params[:contest_id].present?  ? illustration_path(result.id,contest: params[:contest_id].to_i) : illustration_path(result.id)
      },
      :view =>{
        rel: 'view',
        uri: view_illustration_path(result.id)
      },
      :create_story => {
        rel: 'story',
        #uri: params[:search][:contest_id].present? ? new_story_from_illustration_path(result.id, :contest_id => params[:search][:contest_id].to_i) : new_story_from_illustration_path(result.id)
        uri: params[:contest_id].present? ? create_story_from_illustration_path(:id => result.id, :contest_id => params[:contest_id].to_i) : create_story_from_illustration_path(:id => result.id)
      },
      download: {
        high_res_image_url: download_illustrations_path(result.id,:style => "original"),
        low_res_image_url: download_illustrations_path(result.id,:style => "large")
      }
    ]
    sanitized_response[:can_user_like_illustration] = user_signed_in? && !has_user_liked_illustration(result)
    sanitized_response[:user_likes_illustration] = user_signed_in? && has_user_liked_illustration(result)
    contest_id = params[:contest_id].present? ? params[:contest_id].to_i : (params[:search][:contest_id].present? ? params[:search][:contest_id].to_i : nil)
    sanitized_response[:contest_id] = (!params[:contest_id].nil? || !params[:search][:contest_id].nil?) && result.contest_id.include?(contest_id) ? true : false
    sanitized_response[:is_favorite] = (!params[:story_id].nil? && result.favorites &&result.favorites.include?(params[:story_id].to_i)) ? true : false
    sanitized_response[:promotion_manager] = current_user ? ((current_user.promotion_manager? || current_user.content_manager?) ? true : false ) : false
    sanitized_response[:contest_present] = !params[:contest_id].nil? || !params[:search][:contest_id].nil? ? true : false
    sanitized_response[:created_by_child] = result.child_illustrators.present? ? true : false
    sanitized_response
  end

  def has_user_liked_illustration(illustration)
    illustration.liked_users.include?(current_user.id)
  end

  def download_file(illustration,style)
    if Rails.env.production?
      content_type = illustration.image.content_type
      extname = File.extname(illustration.image.to_s)[1..-1].split("?").first
      url = illustration.image.url(style)
      data = open(url)
      send_data data.read, :filename => "#{illustration.name}.#{extname}", :type => content_type , :dispostion=>'inline', :status=>'200 OK', :stream=>'true'
    else
        head(:not_found) and return if illustration.nil?
        extname = File.extname(illustration.image.to_s)[1..-1].split("?").first
        send_file "#{Rails.root.to_s}/public/system/story-weaver/#{illustration.image.path(style)}", :filename=>"#{illustration.name}.#{extname}", :dispostion=>'inline'
    end
  end
end
