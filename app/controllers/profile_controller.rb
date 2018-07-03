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
    @stories = current_user.stories.page(params[:page]).per(10).where(status: Story.statuses[:published])
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
    @drafts = if current_user.role == "content_manager"
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
    @edit_in_progress_stories = current_user.stories.page(params[:page]).per(10).where(status: Story.statuses[:edit_in_progress])
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
