class ContestsController < ApplicationController

  before_action :authenticate_user!, :except   => [:show, :contest_winners_details, :phonestories, :watchout, :did_you_hear, :wild_cat, :phonestories2, :miss_laya_fantastic_motorbike, :miss_laya_fantastic_motorbike_hungry, :miss_laya_fantastic_motorbike_big_box]
  before_action :authorize_action, :except   => [:show,  :contest_winners_details, :illustration_form, :create_illustration, :phonestories, :watchout, :did_you_hear, :wild_cat, :phonestories2, :miss_laya_fantastic_motorbike, :miss_laya_fantastic_motorbike_hungry, :miss_laya_fantastic_motorbike_big_box]

  def index
    @contests = Contest.all.reorder("created_at DESC")
  end

  def show
    @contest = Contest.find(params[:id])
    if !@contest.is_running?
      redirect_to contest_winners_details_path(:contest => @contest.id)
    end
  end

  def new
    @contest = Contest.new
    @contest.build_story_category
  end

  def create
    params[:contest][:story_category_attributes][:private] = true
     @contest = Contest.new(contest_params)
     if @contest.save
      redirect_to contests_path
     else
      flash[:errors] = @contest.errors.messages
      redirect_to new_contest_path
     end     
  end

  def edit
    @contest = Contest.find(params[:id])
  end
  
  def update
    @contest = Contest.find(params[:id])
    params[:contest][:story_category_attributes][:private] = true if params[:contest][:story_category_attributes].present?
    if @contest.update_attributes(contest_params)
      redirect_to contests_path
    else
      flash[:errors] = @contest.errors.messages
      redirect_to edit_contest_path(@contest)
    end
  end

  def contest_details
    @contest = Contest.find(params[:id])
    @current_subtab = params[:reviewed].present? ? params[:reviewed] : "un-reviewed"

    if @contest.contest_type == "illustration"
      @illustrations = @contest.illustrations
      render "illustration_contest"
    elsif @contest.is_campaign == true
      @stories = Story.tagged_with(@contest.tag_name).all 
      render "campaign_details"
    elsif @contest.contest_type == "story" && @contest.is_campaign == false
      @current_tab = params[:filter].present? ? params[:filter] : "adult"
      if params[:filter] == "over_view"
        rrr_contest_overview
      elsif params[:filter] == "child"
        if params[:reviewed] == "reviewed"
          @story = Story.includes(:ratings, :youngsters).reorder("ratings.user_id DESC").where("ratings.user_id = ?", current_user.id).where(:contest => @contest, :status => Story.statuses[:submitted])
        else
          @story = Story.includes(:ratings, :youngsters).reorder("ratings.user_id DESC").where("ratings.user_id IS ? OR ratings.user_id != ?", nil, current_user.id).where(:contest => @contest, :status => Story.statuses[:submitted]) 
          @rating = Rating.new
        end
      else
        if params[:reviewed] == "reviewed"
          @story = Story.includes(:ratings, :youngsters).reorder("ratings.user_rating DESC").where("ratings.user_id = ?", current_user.id).where(:contest => @contest, :status => Story.statuses[:submitted])
        else
          @rating = Rating.new
          @story = Story.includes(:ratings, :youngsters).reorder("ratings.user_id DESC").where("ratings.user_id IS ? OR ratings.user_id != ?", nil, current_user.id).where(:contest => @contest, :status => Story.statuses[:submitted])
        end
      end
    end
  end

  def story_rating_comments
    story = Story.find(params[:rating][:story_id])
    @ratings = Rating.new
    @ratings.rateable = story
    @ratings.user_id = current_user.id
    @ratings.user_comment = params[:rating][:user_comment]
    @ratings.user_rating = params[:rating][:user_rating]
    @contest = Contest.find(params[:rating][:contest_id])
    if @ratings.save
      redirect_to contest_details_path(@contest.id, :filter => params[:rating][:filter], :reviewed => "reviewed")
    else
      flash[:errors] = @ratings.errors.messages
      redirect_to contest_details_path(@contest.id, :filter => params[:rating][:filter], :reviewed => "un-reviewed")
    end
  end

  def user_update_rating_comments
    @ratings = Rating.where(:user_id => params[:current_user_id], :rateable_id => params[:story_id])
    if @ratings.first.update_attributes(:user_rating => params[:rating], :user_comment => params[:comment])
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end

  def user_update_rating_without_comments
    @ratings = Rating.where(:user_id => params[:current_user_id], :rateable_id => params[:story_id])
    if @ratings.first.update_attributes(:user_rating => params[:rating], :user_comment => params[:comment])
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end

  def get_stories(status)
    @stories = Story.where(:contest_id => @contest.id, :status => status)
    @stories_draft = Story.where(:contest_id => @contest.id, :status => Story.statuses[:draft], :dummy_draft => false)
    @all = {}
  end

  def get_statistics(story, type)
    puts story.language.name
    puts type
    puts @all[story.language.name][type]
    @all[story.language.name][type] ||=0
    @all[story.language.name][type] +=1
    unless type == "total"
      @all["Total"][type] ||=0
      @all["Total"][type] +=1
    end
  end

  def contest_draft_stories
    @contest = Contest.find(params[:id])
    @stories = Story.where("status =? OR status =?", Story.statuses[:draft],Story.statuses[:published]).where(:contest_id => params[:id])
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data @stories.to_csv, filename: "contest-draft-users-#{Date.today}.csv"}
    end
  end

  def contest_winners_details
    @contest = Contest.find(params[:id]) if params[:id].present?
  end

  def illustration_form
    @contest = Contest.find(params[:id])
    @illustration = Illustration.new
    @illustration1 = Illustration.new
    @story = Story.new
    @illustration.illustrators.build
    respond_to do |format|
      format.html{}
      format.js
    end
  end

  def create_illustration
    @contest = Contest.find(params[:contest_id])
    params[:illustration][:tag_list] = "#{@contest.name}," + params[:illustration][:tag_list]
    @story = Story.new
    @story.language = Language.find(params[:language])
    @story.reading_level = params[:reading_level]
    @story.orientation = "landscape"
    @story.contest_id = @contest.id
    @illustration = Illustration.new(illustration_params)
    @illustration.license_type = 2
    @illustration1 = Illustration.new()
    @illustration1.image = params[:image]
    @illustration1.name = params[:answer_key_name]
    @illustration1.category_ids = params[:illustration][:category_ids]
    @illustration1.style_ids = params[:illustration][:style_ids]
    @illustration1.tag_list = params[:illustration][:tag_list]
    @illustration1.license_type = 2
    main_illu_name = Illustration.find_by_name(@illustration.name).present?
    key_illu_name = Illustration.find_by_name(@illustration1.name).present?
    if !main_illu_name && !key_illu_name
      if @illustration.set_contest_illustrators(current_user) && @illustration1.set_contest_illustrators(current_user)
        @illustration.set_copyright(params[:illustration],current_user)
        @illustration1.set_copyright(params[:illustration],current_user)
        story_creation_from_illustration
      else
        flash.now[:error] = @illustration.errors.full_messages.join(", ") + @illustration1.errors.full_messages.join(", ")
        respond_to do |format|
          format.html{}
          format.js{ render "illustration_form" }
        end
      end  
    else
      if main_illu_name && key_illu_name
        @illustration.errors[:base] = "Main and Key illustration names are already taken. Please use an alternate names."
      elsif main_illu_name
        @illustration.errors[:base] = "Main illustration name is already taken. Please use an alternate name."
      elsif key_illu_name
       @illustration.errors[:base] = "Key illustration name is already taken. Please use an alternate name."
      end

      respond_to do |format|
        format.html{}
        format.js{ render "illustration_form" }
      end
    end
  end

  def story_creation_from_illustration
    if current_user.organization? 
      @story.organization = current_user.organization
      @story.status = Story.statuses[:uploaded]
    else
      @story.authors = [current_user]
    end
    @story.title = Story.generate_title_for @story 
    if @story.save && @story.contest_build_book(@illustration1,@illustration)
      PiwikEvent.create(category: 'Story',action: 'Create',name: 'Online')
      PiwikEvent.create(category: 'Story - Language',action: "Create - #{@story.language.name}")
      PiwikEvent.create(category: 'Story - Level',action: "Create - #{@story.reading_level}")
      respond_to do |format|
        format.html { redirect_to story_editor_path(@story) }
        format.js {render :contest_story_create }
      end
    else
      @errors=@story.errors.full_messages.join(", ")
      respond_to do |format|
        format.html{}
        format.js{ render "illustration_form" }
      end
    end
  end

  def validate_illustration_name
    illustration = Illustration.find_by_name(params[:image_name].strip())
    render :json => {:status => illustration.present? ? true : false}
  end

  def phonestories    
  end

  def watchout    
  end

  def did_you_hear    
  end

  def wild_cat    
  end

  def phonestories2    
  end

  def miss_laya_fantastic_motorbike    
  end

  def miss_laya_fantastic_motorbike_hungry    
  end

  def miss_laya_fantastic_motorbike_big_box
    
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
        :sort,
        :copy_right_year,
        :copy_right_holder_id,
        category_ids: [],
        style_ids: [],
        child_illustrators_attributes:[:id, :name, :age, :_destroy]
        )
  end

  def contest_params  
    params.require(:contest).permit(
      :name,
      :contest_type,
      :start_date,
      :is_campaign,
      :end_date,
      :tag_name,
      :tag_list,
      :custom_flash_notice,
      language_ids: [],
      story_category_attributes: [:id, :name, :private]
    )
  end

  def authorize_action
    authorize self, :default
  end

end
