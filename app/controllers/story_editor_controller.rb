class StoryEditorController < ApplicationController
  include ImageCrop
  NUMBER_OF_ILLUSTRATIONS = 12
  autocomplete :user, :email, :extra_data => [:email, :bio, :first_name, :last_name]

  before_action :get_illustrations, :only => [:story, :get_all_illustrations, :get_favourite_illustrations, :illustration_drawer, :storycard_crop, :storycard_image_upload]
  before_action :authenticate_user!, except: [:autocomplete_user_email, :get_email]
  include TextEditor::TextboxGenerator

  def story
    @story = Story.find_by_id params[:id]
    @illustration = Illustration.new
    @illustration.illustrators.build
    @contest = Contest.find_by_id params[:contest_id]
    authorize @story, :edit?
    if @story.nil?
      flash[:error]="Unable to find story"
      redirect_to root_path
      return
    end
    # includes textboxes only possible for story page and front cover page by default 
    # second page is story page, please make sure than only story page or front cover page is selected
    if @story.pages.second.is_story_page? || @story.pages.second.is_front_cover_page?
      @page = @story.pages.includes(:textboxes).second
    else
      @page = @story.pages.second
    end
    get_templates(@page)
    render :layout => 'editor'
  end

  def update_dummy_draft
    @story = Story.find(params[:id])
    params[:story][:dummy_draft] = false
    session[:start_with_images] = true if params[:commit] == "start with images"
    @story.user_title = true if story_params[:title].present?
    unless @story.update_attributes(story_params)
      @errors=@story.errors.full_messages.join(", ")
      render :new
    end
    @page = @story.story_pages.first
    @story_page_template = StoryPageTemplate.get_default_template(@story, @story.orientation)
    @page.update_page_template(@story_page_template, true)
    get_templates(@page)
    @story = Story.find(@page.story)
  end


  def new_illustration
    @story_id = params[:story_id] if params[:story_id].present?
    @story = Story.find(@story_id) if params[:story_id].present?
    @contest = @story.contest if @story
    @illustration = Illustration.new
    @illustration.illustrators.build 
    respond_to do |format|
       format.html{}
       format.js
    end
  end

  def create_illustration
    @illustration = Illustration.new(illustration_params)
    respond_to do |format|
      if @illustration.set_illustrator(params[:illustration],current_user)
        format.js { }
      else
        flash.now[:error]=@illustration.errors.full_messages.join(", ")
        format.html{ render "illustrations/new" }
        format.js
      end
    end
  end



  def crop_illustration
    begin
      @illustration = Illustration.find_by_id(params[:id])
      @page = Page.find_by_id(params[:page_id])
      @story = @page.story
      @illustration.favorites << @story unless @illustration.favorites.find_by_id(@story)
      @illustration.reindex

      ratio_x=params["imgInitW"].to_i/params["imgW"].to_f
      ratio_y=params["imgInitH"].to_i/params["imgH"].to_f
      x = params[:imgX1].to_f * ratio_x
      y = params[:imgY1].to_f * ratio_y

      @illustration_crop = @illustration.illustration_crops.new
      crop_details = {
	x: x,
	y: y,
	ratio_x: ratio_x,
	ratio_y: ratio_y,
	crop_x: params[:cropW].to_i,
	crop_y: params[:cropH].to_i
      }
      if params['scale']
	crop_details['scale'] = params['scale']
      end
      @illustration_crop.save_crop_data!(crop_details)

      original_image_dimension = @illustration.image_geometry(:original)
      original_image_width = original_image_dimension.width
      original_image_height = original_image_dimension.height
      ratio_x=original_image_width/params["imgW"].to_f
      ratio_y=original_image_height/params["imgH"].to_f

      original_x = params[:imgX1].to_f * ratio_x
      original_y = params[:imgY1].to_f * ratio_y

      original_w = params[:isGif].nil? ?  params["cropW"].to_f * ratio_x : nil
      original_h = params[:isGif].nil? ? params["cropH"].to_f * ratio_y : nil

      Delayed::Job.enqueue Jobs::ProcessIllustrationCrop.new(@illustration.id, @illustration_crop, @page,original_x,original_y,original_w,original_h)
      if @page.is_front_cover_page? && @story.story_card_id.present?
        @story.story_card.destroy
        @story.update(:story_card_id => nil)
      end
      if(@illustration_crop && @page.update_attributes(:illustration_crop => @illustration_crop))

        illustration_url = @illustration.image.url(:original_for_web)

        crop_ratio = @page.image_type != "image/gif" ? 8.23 : 1
	left, top, width, height = get_image_dimensions(@page)
	unit = @page.image_type == "image/gif" ? "%" : "px"

	if params["story_card_cropper"]
          respond_to do |format|
            format.html {}
            format.js {render :storycard_crop_save} 
          end
	else
          render :json => {
                   "status"  =>  "success",
                    "url"     =>  illustration_url,
                    "top"  => "#{-top}#{unit}",
                    "left"  => "#{-left}#{unit}",
                    "width" => "#{width}#{unit}",
                    "height" => "#{height}#{unit}",
                    "id" => @illustration.id,
                    "thumb_url" => illustration_url,
                    "thumb_top" => "#{-top/crop_ratio}#{unit}",
                    "thumb_left" => "#{-left/crop_ratio}#{unit}",
                    "thumb_width" => "#{(width/crop_ratio rescue nil)}#{unit}",
                    "thumb_height" => "#{(height/crop_ratio rescue nil)}#{unit}"
          }
	end
      else
        render(:json => {
          "status"  =>"error",
          "message" =>  "Illustration not found!"
        }, :status  =>  422)
      end
    rescue Exception => e
      logger.error(e.backtrace)
      render(:json => {
          "status"  =>"error",
          "message" =>  "An error occurred! #{e.message}"
        }, :status  =>  500)
    end
  end

  def translation_feedback
    @story = Story
    .eager_load(:categories)
    .find_by_id(params[:id])
    @categories = (current_user.content_manager? || current_user.organization?) ? StoryCategory.all : StoryCategory.where(private: false)
    @contest = @story.contest
    @translation_feedback = TranslationFeedback.new
    @translation_feedback.story = @story
    @translation_feedback.user = current_user
    @translation_feedback.feedback = Story::TRANSLATION_FEEDBACKS[params[:translation_feedback][:feedback]]
    unless @translation_feedback.save
      @record_not_saved = true
    end
  end

  def illustration_for_crop
    begin
      illustration = Illustration.find_by_id params[:id]
      page = Page.find(params[:page_id])
      illustration_crop = page.illustration_crop
      if illustration
        illustration_dimension = illustration.image_geometry(:original_for_web)
        illustration_width = illustration_dimension.width
        illustration_height = illustration_dimension.height
        illustration_url = illustration.image.url(:original_for_web)
        if(illustration_crop)
          crop_details = illustration_crop.parsed_crop_details
          if illustration_crop.image != nil && illustration_crop.image.exists?
            if illustration_crop.image.try(:url) == "/images/original/missing.png" || illustration_crop.image.processing?
              crop_width = (illustration_width/crop_details["ratio_x"] rescue 0)
              crop_width = default_width(page, illustration_width) if width == 0
            else
              illustration_crop_geo = illustration_crop.image_geometry(:original)
              crop_width = illustration_crop_geo.width
            end
          else
            crop_width = (illustration_width/crop_details["ratio_x"] rescue 0)
            crop_width = default_width(page, illustration_width) if crop_width == 0
          end

          crop_window_width = crop_details["crop_x"]
          zoom = (illustration_width/crop_width-1.0)*crop_window_width rescue 1;
        end
        render :json => {
          "status"  =>  "success",
          "url"     =>  illustration_url,
          "width"   =>  illustration_width,
          "height"  =>  illustration_height,
          "zoom"    =>  zoom||1,
          "x"       =>  (crop_details["x"]/crop_details["ratio_x"] rescue 0),
          "y"       =>  (crop_details["y"]/crop_details["ratio_y"] rescue 0),
          "format"  =>  illustration.image_content_type
        }
      else
        render(:json => {
          "status"  =>"error",
          "message" =>  "Illustration not found!"
        }, :status  =>  422)
      end
    rescue Exception => e
      logger.error(e.backtrace)
      render(:json => {
          "status"  =>"error",
          "message" =>  "An error occurred! #{e.message}"
        }, :status  =>  500)
    end
  end

  def edit_book_info
    @story = Story
                 .eager_load(:categories)
                 .find_by_id(params[:id])
    @categories = (current_user.content_manager? || current_user.organization?) ? StoryCategory.all : StoryCategory.where(private: false)
    @contest = @story.contest
    respond_to do |format|
      format.html { }
      format.js
    end
  end

  def language_script
    script = Language.find_by_id(params[:lang_id]).script
    render json: {"language_script" => script}
  end

  def default_width(page, illu_width)
    pg_tmp = page.page_template
    template_width = pg_tmp.orientation.to_s == 'landscape' ?
      (pg_tmp.image_position == 'left' ?
        (959*pg_tmp.image_dimension)/100 : 959) : 475
    illu_width/(illu_width/template_width)
  end

  def search_illustration
    params.merge!(size: NUMBER_OF_ILLUSTRATIONS)
    @illustrations = Search::Illustrations
      .search(params)
      .results
    respond_to do |format|
      format.html { }
      format.js {render :search }
    end
  end

  def page_edit
    @page = Page.find_by_id(params[:id])
    @story = @page.story
    get_templates(@page)
    respond_to do |format|
      format.html { }
      format.js
    end
  end

  def remove_page_illustration
    @page = Page.find_by_id(params[:id])
    @story = @page.story
    @page.illustration_crop = nil
    @page.save!

    respond_to do |format|
      format.html { }
      format.js { }
    end
  end

  def update_page_illustration
    @page = Page.find_by_id(params[:id])
    @story = @page.story
    @illustration = Illustration.find_by_id(page_params[:illustration_id])
    #@page.illustration_crop.destroy if @page.illustration_crop.present?
    @page.reload

    respond_to do |format|
      format.html { }
      format.js { }
    end
  end

  def update_page_content
    @page = Page.find_by_id(params[:id])
    @story = @page.story
    @page.update_attributes(content: page_params[:content])
    respond_to do |format|
      format.html { }
      format.js { }
    end
  end

  def auto_save_content
    @page = Page.find_by_id(params[:id])
    @story = @page.story
    @page.page_content_update(page_params[:content], params[:textbox_id])
    respond_to do |format|
      format.html { }
      format.js { }
    end
  end
  def save_content_on_blur
    @page = Page.find_by_id(params[:id])
    @story = @page.story
    @page.page_content_update(page_params[:content], params[:textbox_id])
    respond_to do |format|
      format.html { }
      format.js { }
    end
  end

  def change_page_template
    @page = Page.find_by_id(params[:page_id])
    @story = @page.story
    @story_page_template = PageTemplate.find_by_id(params[:id])
    @page.update_page_template(@story_page_template, @story.is_orientation_changed(@story_page_template.orientation))
    @page.update_page_illustration_crop if @page.illustration_crop.present? && @story_page_template.is_full_text_template?
    get_templates(@page)
    @story = Story.find(@page.story)
    respond_to do |format|
      format.html { }
      format.js
    end
  end

  def insert_page
    @story = Story.find_by_id params[:story_id]
    selected_page = Page.find_by_id(params[:id])
    get_templates(selected_page)
    params[:number_of_pages].to_i.times do
      @page = StoryPage.new page_template: selected_page.page_template
      @story.insert_page(@page,selected_page)
    end
    @story.save
    respond_to do |format|
      format.html { }
      format.js
    end
  end

  def duplicate_page
    @story = Story.find_by_id params[:story_id]
    page = Page.find_by_id(params[:id])
    get_templates(page)
    @page = page.dup
    unless page.illustration_crop.nil?
      @page.illustration_crop_id = page.illustration_crop_id
    end
    @story.insert_page(@page,page)

    if page.try(:textboxes).present?
      @textboxes = page.textboxes.map(&:dup)
      @page.textboxes << @textboxes
    end
    @story.save

    respond_to do |format|
      format.html { }
      format.js
    end
  end

  def delete_page
    @story = Story.find_by_id params[:story_id]
    delete_page = Page.find_by_id(params[:id])
    get_templates(delete_page)
    @page = delete_page.is_front_cover_page? ? delete_page : delete_page.higher_item

    if delete_page.is_story_page?
      delete_page.remove_from_list
      delete_page.destroy
    end

    respond_to do |format|
      format.html { }
      format.js
    end
  end

  def rearrange_page
    @story = Story.find_by_id(params[:id])
    @page = Page.find_by_id(page_params[:page_id])
    get_templates(@page)
    @page.set_list_position(page_params[:position])

    respond_to do |format|
      format.html { }
      format.js
    end
  end

  def validate_story_pages
    @story = Story
    .eager_load({:pages=>[:page_template,:illustration_crop]})
    .find_by_id(params[:id])
    @image_errors = []
    @orientation_errors = []
    @textbox_errors = @story.has_textbox_empty ? render_to_string( partial: 'textbox_empty_warning').strip().to_json : '' 

    @story.pages.order(:position).each do |page|
      @image_errors << page.position if page.page_template.image_mandatory? && page.illustration_crop.nil?
      @orientation_errors << page.position if page.page_template.orientation != @story.orientation
    end
    respond_to do |format|
      format.html { }
      format.js
    end
  end

  def storycard_crop
    @story = Story.find_by_id(params[:id])

    front_page = @story.pages[0]
    front_page_illustration = front_page.illustration
    illustration_crop = @story.story_card_illustration_crop

    if @story.story_card_id.nil?
      front_page_illustration_crop = front_page.illustration_crop
      previous_story_card_id = @story.story_card_id
      front_page_illustration.process_illustration_smart_crop( front_page, front_page_illustration_crop )
      @story.reload
      illustration_crop = @story.story_card_illustration_crop
      StoryCard.find_by_id(previous_story_card_id).try(:destroy) if previous_story_card_id
    end

    @crop_details = illustration_crop.parsed_crop_details
    @illustration = illustration_crop.illustration

    respond_to do |format|
      format.html { }
      format.js
    end
  end


  def storycard_image_upload 
    @story = Story.find_by_id(params[:id])
    @illustration = Illustration.find_by_id(params[:illustration_id])
    crop_details = @illustration.generate_smart_crop_details
    @crop_details = @illustration.generate_crop_details(crop_details)

    respond_to do |format|
      format.html {}
      format.js  {render :storycard_crop } 
    end
  end
  

  def publish_form
    @story = Story
    .eager_load(:categories)
    .find_by_id(params[:id])
    @categories = (current_user.content_manager? || current_user.organization?) ? StoryCategory.all : StoryCategory.where(private: false)
    @contest = @story.contest
    respond_to do |format|
      format.html { }
      format.js
    end
    @translation_feedback = TranslationFeedback.new if @story.is_autoTranslate
  end

  def upload_illustration
    @story = Story.find(params[:story_id])
    @illustration = Illustration.new
    @illustration.illustrators.build
  end

  def get_all_illustrations
    @story = Story.find(params[:story_id])

  end

  def get_favourite_illustrations
   @story = Story.find(params[:story_id])
  end

  def publish
    @story = Story
    .eager_load(:categories)
    .find_by_id(params[:id])
    @contest = @story.contest
    @categories = (current_user.content_manager? || current_user.organization?) ? StoryCategory.all : StoryCategory.where(private: false)
    authorize @story, :publish?
    copy_right_holder_id = User.find_by_email(params[:story][:copy_right_holder_id].strip) if params[:story][:copy_right_holder_id].present?
    params[:story][:copy_right_holder_id] = copy_right_holder_id.present? ?  copy_right_holder_id.id : nil
    story_status = @story.status
    respond_to do |format|
      if @story.update_and_publish(story_params, params[:story][:authors_attributes] || [], current_user)
        AudioUpload::AudioUploader.new.audio_page_content(@story) if @story.is_audio
        flash.clear
        @contest = @story.contest
        @current_user = current_user
        if @story.contest_id != nil && @contest.is_running? && @contest.is_campaign == false
          session[:submitted_story_notice] = true;
          format.html{ }
          format.js{ render "submitted_stories" }
        else
          if story_status == "edit_in_progress"
            flash[:notice] = "Your story has been re-published successfully. You can find it by searching for the title name on our home page."
          else
            if @story.contest_id != nil && @contest.is_campaign == true && @contest.custom_flash_notice.present?
              @is_campaign_page = true
              format.js{ render "publish" }
              flash[:notice] = @contest.custom_flash_notice 
            else
              flash[:notice] = "Wohooo! Your story will appear on the New Arrivals in a short while."
            end
            flash[:alert] = @story.root.publish_message
          end
          format.html{ }
          format.js{ render "publish" }
        end
      else  
        flash.now[:error] = @story.errors.full_messages.join(", ")
        format.html
        format.js{ render "publish_form" }
      end
    end
  end
  
  def update
    @story = Story
    .eager_load(:categories)
    .find_by_id(params[:id])
    @categories = (current_user.content_manager? || current_user.organization?) ? StoryCategory.all : StoryCategory.where(private: false)
    copy_right_holder_id = User.find_by_email(params[:story][:copy_right_holder_id].strip) if params[:story][:copy_right_holder_id].present?
    params[:story][:copy_right_holder_id] = copy_right_holder_id.present? ?  copy_right_holder_id.id : nil
    respond_to do |format|
      if @story.update_and_publish(story_params, params[:story][:authors_attributes] || [], current_user, true)
        flash.clear
        if @story.contest && @story.contest.is_running? #DTC
          flash[:notice] = "Your entry for Delhi Teachers Contest has been saved as a draft under 'My Drafts' on your profile page."
        else
         flash[:notice] = "Your story has been saved as a draft. You can edit, complete and publish your story by clicking on 'My Drafts' on your profile page."
        end
        format.html{ }
        format.js{ render "update" }
      else
        flash.now[:error] = @story.errors.full_messages.join(", ")
        format.html
        format.js{ render "publish_form" }
      end
    end
  end

  def update_book_info
    @story = Story
             .eager_load(:categories)
             .find_by_id(params[:id])
    params[:story].merge!(user_title: params[:story][:title].strip != '' ? true : false)
    @story.update(story_params)
  end

  def save_to_draft
    if params[:contest] == "true" #DTC
      flash[:notice] = "Your entry for Delhi Teachers Contest has been saved as a draft under 'My Drafts' on your profile page."
    else
     flash[:notice] = "Your story has been saved as a draft. You can edit, complete and publish your story by clicking on 'My Drafts' on your profile page."
    end
     redirect_to root_path
  end

  def get_email
    @user = User.find_by_email(params[:email])
    if @user
     @user.update_attributes(:editor_feedback => true)
     @user.save!
   end
    render :json => {"values" => @user.present? ? "User details updated" : "User not Found"}
  end
  
  private

  def page_params
    params
      .require(:page)
      .permit(:content, :illustration_id,:page_id,:position)
  end

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
      :tag_list,
      :license_type,
      category_ids: [],
      style_ids: []
    )
  end

  def get_illustrations
     @illustrations = Search::Illustrations.search(size: NUMBER_OF_ILLUSTRATIONS).results
     @categories = IllustrationCategory.all
     @styles = IllustrationStyle.all
    @organizations = Organization.all
  end

  def get_templates(page)
    @template_options = page.page_template.get_similar_templates
  end

  def story_params
    params.require(:story).permit(
      :title,
      :english_title,
      :synopsis,
      :reading_level,
      :attribution_text,
      :copy_right_year,
      :chaild_created,
      :dedication,
      :more_info,
      :copy_right_holder_id,
      :organization_id,
      :donor_id,
      :credit_line,
      :tag_list,
      :user_title,
      :language_id,
      :orientation,
      :dummy_draft,
      category_ids: [],
      youngsters_attributes:[:id, :name, :age, :_destroy],
    )
  end
end
