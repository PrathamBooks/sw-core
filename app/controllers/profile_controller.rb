include ApplicationHelper

class ProfileController < ApplicationController

  before_action :authenticate_user!
  before_action :get_users, on: [:flag_story]

  def index
    @current_tab = 'details'
  end

  def edit
    @current_tab = 'details'
    current_user.update_attributes(:first_name => params[:user][:first_name],
      :last_name => params[:user][:last_name], :email_preference => params[:user][:email_preference], 
      :website => params[:user][:website], :bio => params[:user][:bio], :language_preferences => params[:user][:language_preferences].reject(&:empty?).join(','),
      :reading_levels => params[:user][:reading_levels].reject(&:empty?).join(',')) || flash[:errors] = current_user.errors.messages
    redirect_to profile_path
    flash[:notice] = "Your changes have been saved."
  end

  def edit_password
    @user = current_user
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end 

  def update_password
    @user = current_user
    @user.errors.add(:password,"old password and new password should be different") if user_params[:current_password] == user_params[:password] && 
    (!user_params[:current_password].blank? && !user_params[:password].blank?)
    @user.errors.add(:password,"can't be blank") if user_params[:password].blank?
    @user.errors.add(:password_confirmation, "can't be blank") if user_params[:password_confirmation].blank?
    @user.errors.add(:current_password, "can't be blank") if user_params[:current_password].blank?
    if @user.errors.blank? && @user.update_with_password(user_params)
      flash[:notice] = "Password updated successfully!"
      respond_to do |format|
        format.html
        format.js {render js: "window.location = '/users/sign_in'"}
      end
    else
      respond_to do |format|
        format.html {}
        format.js {render :edit_password}
      end
    end
  end

  def stories
    @current_tab = 'stories'
    @stories = if current_user.organization? 
        Story.page(params[:page]).per(10).where(status: Story.statuses[:published],organization: current_user.organization )
      else
        current_user.stories.page(params[:page]).per(10).where(status: Story.statuses[:published])
      end
    render "index"
  end

  def illustrations
    @current_tab = 'illustrations'
    illustrator = current_user.person
    @illustrations = illustrator.illustrations.page(params[:page]).per(10) if illustrator
    render "index"
  end

  def drafts
    @current_tab = 'drafts'
    @drafts = if current_user.organization?
                Story.page(params[:page]).per(10).where(status: Story.statuses[:uploaded],organization: current_user.organization, dummy_draft: false )
              elsif current_user.role == "content_manager"
                Story.where(status: Story.statuses[:draft], dummy_draft: false)
                     .joins(:authors)
                     .where("authors_stories.user_id = ? or stories.organization_id IS NOT NULL",@current_user)   
                     .page(params[:page]).per(10)             
              else
                current_user.stories.page(params[:page]).per(10).where(status: Story.statuses[:draft], dummy_draft: false)
              end
    render "index"
  end

  def delete_draft
    story = Story.find_by_id(params[:id])
    @redirect_path = story.dummy_draft? ? root_path : profile_drafts_path
    flash[:error] = "Unable to find story with this id" if story.nil?

    if story.draft? && story.is_childless? || (story.uploaded? && current_user.organization? && story.is_childless?)
      story.destroy
      respond_to do |format|
        format.html {
          flash[:notice] = "Draft deleted successfully"
          redirect_to profile_drafts_path }
        flash[:notice] = "Draft deleted successfully"
        format.js {}
      end
    else
      respond_to do |format|
        format.html {
          flash[:error]="Unable to delete story"
          redirect_to profile_drafts_path
        }
        format.js { render :destroy_error }
      end
    end
  end

  def un_reviewed_stories
    if current_user && (current_user.content_manager? || current_user.languages.any?)
     @current_tab = 'un_reviewed_stories'
     @current_user = current_user
     @languages = @current_user.content_manager? ? Language.all : (@current_user.languages.present? ? @current_user.languages : nil)
     @story_results = Story.joins(:authors).where("authors_stories.user_id !=?",@current_user)
                     .joins("LEFT OUTER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                     .where("reviewer_comments.story_id IS ?", nil)
                     .where(:status => Story.statuses[:published], :language => @languages.collect(&:id),:organization_id => nil, :flaggings_count => nil)
                     .reorder("published_at ASC")
     @stories = get_stories_for_pagination(@story_results)
    else
      flash[:error] = "You are not authorised to do this."
      redirect_to root_path
    end
  end

  def un_translated_stories
    if current_user && current_user.is_translator?
      @current_tab = 'un_translated_stories'
      @current_user = current_user
      @languages = @current_user.tlanguages if @current_user.tlanguages.present?
      at_user = User.find_by first_name:"Auto-Translate"
      @stories = Story.joins(:authors)
                      .where(:is_autoTranslate => true, :status => Story.statuses[:draft],
                             :started_translation_at => nil, :language => @languages.collect(&:id))
                      .uniq.reorder("created_at DESC").page(params[:page]).per(12)
    else
      flash[:error] = "You are not authorised to do this."
      redirect_to root_path
    end
  end

  def un_translated_stories_new
    if current_user && current_user.is_translator?

      # 
      # condition: Translator Story target if present and published it should be no longer available in list of 
      # stories to be translated
      #
      @translator_stories = TranslatorStory.joins("LEFT JOIN stories ON stories.id = translator_stories.translator_story_id").where("translator_id = ? AND (stories.id IS NULL OR stories.status != ? )", current_user.id, Story.statuses[:published]).order(id: :asc)
    else
      flash[:error] = "You are not authorised to do this"
      redirect_to root_path
    end
  end

  def reviewed_stories
    if current_user && (current_user.content_manager? || current_user.languages.any?)
       @current_tab = 'reviewed_stories'
       @current_user = current_user
       @languages = @current_user.content_manager? ? Language.all : (@current_user.languages.present? ? @current_user.languages : nil)
       @stories = Story.select('stories.*,reviewer_comments.created_at')
                       .joins("INNER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                       .where("reviewer_comments.user_id =?", current_user.id)
                       .where(:status => Story.statuses[:published], :language => @languages.collect(&:id), :organization_id => nil, :flaggings_count => nil)
                       .reorder("reviewer_comments.created_at DESC").uniq.page(params[:page]).per(12)
       @languages_sort = ""
     else
       flash[:error] = "You are not authorised to do this."
       redirect_to root_path
    end
  end

  def get_stories_for_pagination(story_results)
    stories_array = []
    story_results.map{|s| stories_array.push(s) if s.get_reviewer_stories(@current_user)}
    return Kaminari.paginate_array(stories_array).page(params[:page]).per(12)
  end

  def get_reviewer_language_stories
      @current_user = current_user
      @languages = @current_user.content_manager? ? Language.all : (@current_user.languages.present? ? @current_user.languages : nil)
      conditions = {:status => Story.statuses[:published], :organization_id => nil, :flaggings_count => nil}
      @language = Language.find_by_name(params[:language]) if params[:language] && params[:language] != ''
      conditions[:language] = @language.present? ? @language.id : @languages.collect(&:id)
      conditions[:reading_level] = params[:level] if params[:level] && params[:level] != ''
      @story_type = params[:story_type] == "Original" ? nil : (params[:story_type] == "Translation" ? "translated" : "relevelled") if params[:story_type] && params[:story_type] != ''
      conditions[:derivation_type] = @story_type if params[:story_type] && params[:story_type] != ''
      @languages_sort = params[:language]
    if params[:current_tab] == "un_reviewed_stories"
      @current_tab = 'un_reviewed_stories'
      @story_results = Story.joins(:authors).where("authors_stories.user_id !=?",@current_user)
                      .joins("LEFT OUTER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                      .where("reviewer_comments.story_id IS ?", nil)
                      .where(conditions).reorder("published_at ASC")
      @stories = get_stories_for_pagination(@story_results)
    else
      @current_tab = 'reviewed_stories'
      @stories = Story.select('stories.*,reviewer_comments.created_at')
                      .joins("INNER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                      .where("reviewer_comments.user_id =?", current_user.id).where(conditions)
                      .order("reviewer_comments.created_at DESC").uniq.page(params[:page]).per(12)
    end  
    @page = "language_stories"
  end

  def get_translator_language_stories
    @current_user = current_user
    @languages = @current_user.tlanguages if @current_user.tlanguages.present?
    conditions = {:flaggings_count => nil}
    @language = Language.find_by_name(params[:language]) if params[:language] && params[:language] != ''
    conditions[:language] = @language.present? ? @language.id : @languages.collect(&:id)
    conditions[:reading_level] = params[:level] if params[:level] && params[:level] != ''
    @languages_sort = params[:language]
    at_user = User.find_by first_name:"Auto-Translate"
    if params[:current_tab] == "un_translated_stories"
      @current_tab = 'un_translated_stories'
      @stories = Story.joins(:authors)
                      .where(:is_autoTranslate => true, :status => Story.statuses[:draft], :started_translation_at => nil)
                      .where(conditions)
                      .uniq.page(params[:page]).per(12)
    else 
      @current_tab = 'translated_stories'
      @stories = Story.joins(:authors)
                      .where("authors_stories.user_id = ?", current_user)
                      .where(:status => Story.statuses[:published], :is_autoTranslate => true)
                      .where(conditions)
                      .uniq.page(params[:page]).per(12)
    end  
    @page = "language_stories"
  end

  def change_translator
    s = Story.find(params[:story_id])
    s.authors = [current_user]    
    s.started_translation_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    s.save!
    redirect_to story_editor_path(s)
  end

  def get_translator_language_stories_new
    if current_user && current_user.is_translator?
      conditions = { :translator_id => current_user.id}
      @translator_stories = TranslatorStory.all

      if(params[:level].present? || params[:language].present?)
        @translator_stories = @translator_stories.joins(:story)
      end

      if(params[:level].present?)
        conditions[:"stories.reading_level"] = params[:level]
      end

      if(params[:language].present?)
        conditions[:translate_language_id] = params[:language]
      end

      # 
      # condition 1: Filters for original story if user selected
      # condition 2: If target story is present and published it 
      # should be no longer visible in the translator dashboard
      #
      @translator_stories = @translator_stories.joins("LEFT JOIN stories as target_stories ON target_stories.id = translator_stories.translator_story_id").where(conditions).where("target_stories.id IS NULL OR target_stories.status != ?", Story.statuses[:published]).order(id: :asc)
    else
      flash[:error] = "You are not authorised to do this"
      redirect_to root_path
    end
  end

  def review_guidelines
    @current_tab = 'review_guldelines'
  end

  def translate_guidelines
    @current_tab = 'translate_guidelines'
  end

  def un_edited_stories
    @current_tab = 'un_edited_stories'
    @current_user = current_user
    @stories = Story.where(:editor_id => @current_user, :editor_status => false,:status => Story.statuses[:uploaded]).reorder("updated_at ASC").page(params[:page]).per(12)
  end

  def edited_stories
    @current_tab = 'edited_stories'
    @current_user = current_user
    @stories = Story.where(:editor_id => @current_user, :editor_status => true,:status => Story.statuses[:uploaded]).reorder("updated_at DESC").page(params[:page]).per(12)
  end

   def edit_story_flag
    @story = Story.find_by_id(params[:story_id]) if params[:story_id].present?
    if @story.update_attributes(:editor_status => true)
      respond_to do |format|
        format.html
        format.js {render js: "window.location = '#{profile_edited_stories_path}';"}
      end
    end
   end

   def private_images
    @current_tab = "private_images"
    @illustrations = Illustration.all.where(:image_mode => true, :uploader => current_user).reorder("created_at DESC").page(params[:page]).per(12)
   end

  def make_image_public
    @current_tab = "private_images"
    @illustration = Illustration.find_by_id(params[:id]) if params[:id].present?
    if @illustration.image_mode == true
      @illustration.update_attributes(:image_mode => false)
      flash[:notice] = "Image marked as public successfully " 
      redirect_to :back
    else
      flash[:error] = "Image not marked as public" 
      redirect_to :back
    end
  end

  def user_organization_downloads
    @current_tab = 'organization_downloads'
    @organization = User.find(current_user.id).organization
    @story_downloads =  @organization.users.where(:id => current_user.id).first
                                           .story_downloads.where(:organization_user => true)
                                           .reorder("created_at DESC").page(params[:page]).per(12)
  end

  def deactivated_stories
    @current_tab = 'deactivated'
    @deactivated_stories = current_user.stories.page(params[:page]).per(10).where(status: Story.statuses[:de_activated])
    render "index"
  end

  def submitted_stories
    @current_tab = 'submitted'
    @submitted_stories = current_user.stories.page(params[:page]).per(10).where(status: Story.statuses[:submitted])
    render "index"
  end

  def edit_in_progress
    @current_tab = 'edit_in_progress'
    @edit_in_progress_stories = if current_user.organization?
                                  Story.where(status: Story.statuses[:edit_in_progress])
                                    .joins(:authors)
                                    .where("authors_stories.user_id = ? or stories.organization_id = ?", current_user, current_user.organization_id)
                                    .page(params[:page]).per(10)
                                else
                                  current_user.stories.page(params[:page]).per(10).where(status: Story.statuses[:edit_in_progress])
                                end
    render "index"
  end

  def flag_illustration
    illustration = Illustration.find_by_id(params[:illustration_id])
    user = User.find_by_id(params[:id])
    user.flag(illustration, params[:reason])
  end

  def user_org_details
    @current_tab = "organization_details"
    @org = Organization.find_by_id(params[:org_id])
    unless current_user.is_admin(@org)
      flash[:error] = "You are not authorised to do this."
      redirect_to root_path
    end
  end
 
  def org_logo
    @current_tab = 'details'
    @org = Organization.find_by_id(params[:org_id])
    @org.update_attributes(:logo => params[:org][:logo])
  end

  def profile_image
    @current_tab = 'details'
    current_user.update_attributes(:profile_image => params[:user][:profile_image])
  end

  def edit_org
    @current_tab = 'details'
    @org = Organization.find_by_id(params[:org_id])
    @org.update_attributes(:organization_name => params[:organization][:organization_name],:country => params[:organization][:country],:email => params[:organization][:email], :website => params[:organization][:website],
                            :description => params[:organization][:description],:facebook_url => params[:organization][:facebook_url],
                            :rss_url => params[:organization][:rss_url], :twitter_url => params[:organization][:twitter_url],
                            :youtube_url => params[:organization][:youtube_url], :number_of_classrooms => params[:organization][:number_of_classrooms],
                            :children_impacted => params[:organization][:children_impacted]) || flash[:errors] = @org.errors.messages
    flash[:errors]
    redirect_to user_org_details_path(:org_id => @org.id)
    flash[:notice] = "Your changes have been saved."
  end

  def get_pub_logo_path
    organization_id = params[:organization_id]
    organization = !organization_id.to_s.empty? ? Organization.find(organization_id) : ""
    logo_path = (organization!="") ? (organization.logo.present? ? organization.logo.url(:original) : "") : "#{host_url}/assets/publisher_logos/community.jpg"
    render json: {"logo_path" => logo_path}
  end

  private
  def get_users
    @users = User.normal_users
  end

  def user_params
     params.require(:user).permit(:current_password, :password, :password_confirmation, :email_preference, :language_preferences, :reading_levels)
  end

end
