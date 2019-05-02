include ApplicationHelper
require 'convert_story'

class DashboardController < ApplicationController
  helper_method :sort_column, :sort_direction
  autocomplete :user, :email, :display_value => :user_details, :extra_data => [:email, :bio, :first_name, :last_name, :role]
  EVERYTHING = "*"
  PER_PAGE = 10
  IMPORT_PARTNER_SUB_TAB = "import_partners"
  CONTENT_EXCHANGE_TOKEN_SUB_TAB = "content_exchange_tokens"
  OPDS_MANAGEMENT_TAB = "opds_management"
  before_action :authenticate_user!
  before_action :authorize_action, :except   => [:analytics, :most_read_stories, :most_viewed_illustrations, :most_used_illustrations, :most_downloaded_stories, :most_downloaded_illustrations, :organization_downloads, :story_bulk_downloads , :organization_users,:organization_user, :stories_downloaded_list, :story_downloads_date_sort]
  before_action :analytics_access, :only   => [:analytics, :most_read_stories, :most_viewed_illustrations, :most_used_illustrations, :most_downloaded_stories, :most_downloaded_illustrations, :organization_downloads, :story_bulk_downloads , :organization_users, :organization_user, :stories_downloaded_list, :story_downloads_date_sort]
  before_action :import_partner_check, :only => [:edit_import_partner, :update_import_partner]

  
  DEFAULT_CRITERIA = [
    { _score: {order: :desc} },
    { created_at: {order: :desc} }
  ]

  def index
    @pending_piwik_events = PiwikEvent.all
    @current_tab = "upload"
    @upload_running = upload_running?
    @search_query_dashboard = params[:search].present? ? params[:search][:query] : " "
    results = process_search
    @stories = results.execute
  end

  def upload
    unless upload_running?
      uploader = StoryUpload::Uploader.new
      if uploader.check_input_file
        uploader.upload
      else
        flash[:error]="Unable to find csv file in the path"
      end
    end
    redirect_to dashboard_path
  end

  def images_upload_new
    @current_tab = "image_upload"
    @illustrations = Illustration.search('*', where: { :is_bulk_upload => true }, :load => false)
  end

  def all_stories
    @current_tab = "all_stories"
    @stories = Story.where("created_at >= ? ", 1.month.ago).where(:status => Story.statuses[:published]) if params[:search_from] == "One Month"
    @stories = Story.where("created_at >= ? ", 3.month.ago).where(:status => Story.statuses[:published]) if params[:search_from] == "Three Months"
    @stories = Story.where("created_at >= ? ", 6.month.ago).where(:status => Story.statuses[:published]) if params[:search_from] == "Six Months"
    @stories = Story.where("created_at >= ? ", 1.year.ago).where(:status => Story.statuses[:published]) if params[:search_from] == "One Year"
    @stories = Story.all if params[:search_from] == "All Stories"
    @stories = Story.where("created_at >= ? and created_at <= ?", params[:start_date], params[:end_date]).where(:status => Story.statuses[:published]) if params[:start_date].present? && params[:end_date].present?
  end

  def new_import_partner
    @current_tab = OPDS_MANAGEMENT_TAB
    @import_partner = ImportPartner.new
  end

  def edit_import_partner
  end

  def create_import_partner
    @current_tab = OPDS_MANAGEMENT_TAB
    @sub_tab = IMPORT_PARTNER_SUB_TAB

    import_partner = ImportPartner.new(import_partner_params)
    
    begin
      import_partner.save!
    rescue
      flash[:error] = "Unable to save import partner"
      redirect_to opds_management_path
      return
    end

    flash[:notice] = "Import partner successfully created"
    redirect_to opds_management_path
  end

  def update_import_partner
    begin
      @import_partner.update!(import_partner_params)
    rescue
      flash[:error] = "Unable to update import partner"
      redirect_to opds_management_path
      return
    end
    
    flash[:notice] = "Import partner successfully updated"
    redirect_to opds_management_path
  end

  def new_content_exchange_token
    @current_tab = OPDS_MANAGEMENT_TAB
    @token = Token.new
  end

  def create_content_exchange_token
    @current_tab = OPDS_MANAGEMENT_TAB
    @sub_tab = CONTENT_EXCHANGE_TOKEN_SUB_TAB

    if token_params["organization_id"].empty?
      flash[:error] = "Organization is incorrect. Please choose organization from autocomplete list."
    else
      begin
        token = Token.new(token_params)
        token.access_token = SecureRandom.hex
        token.story_count = token_params[:story_download_limit]
        token.illustration_count = token_params[:illustration_download_limit]
        token.save!
        flash[:notice] = "Token successfully created"
      rescue Exception => ex
        Rails.logger.info "### exception message : #{ex.message} ###"
        flash[:error] = "Unable to save token"
      end
    end

    @import_partners = ImportPartner.all
    @tokens = Token.all

    render "opds_management"
  end

  def delete_content_exchange_token
    token = Token.find_by_id(params[:id])
    if token == nil
      flash[:error] = "Could not find token with ID : #{params[:id]}"
    else
      token.destroy
      flash[:notice] = "Token deleted successfully"
    end
    render :js => "window.location = '#{opds_management_path}?sub_tab=#{CONTENT_EXCHANGE_TOKEN_SUB_TAB}'"
  end

  def opds_management
    @current_tab = OPDS_MANAGEMENT_TAB
    @sub_tab = (params["sub_tab"] == CONTENT_EXCHANGE_TOKEN_SUB_TAB) ? CONTENT_EXCHANGE_TOKEN_SUB_TAB : IMPORT_PARTNER_SUB_TAB
    @import_partners = ImportPartner.all
    @tokens = Token.all
    @story_download_count = 0
    @illustration_download_count = 0
    @tokens.each do |token|
      @story_download_count += (token.story_download_limit - token.story_count)
      @illustration_download_count += (token.illustration_download_limit - token.illustration_count)
    end
  end
  
  def lists
    @current_tab = "lists"
    users = User.where.not(:organization_id => nil)
    @lists = List.where(:user_id => users).without_default_list
  end

  def users_recommended
    @current_tab = "users_recommended"
    smiley_loved_stories = SmileyRating.where(:reaction => "love").collect(&:story_id)
    highly_rated_stories = ReviewerComment.where(:rating => [4, 5]).collect(&:story_id)
    stories = (smiley_loved_stories + highly_rated_stories).uniq
    @users_recommended_stories = (Story.search where: {id: stories, editor_recommended: false}, load: false, execute: false).results
  end
  
  def update_lists
    list = List.find(params[:id])
    # having both organization_id and status is redundant for now to know the published lists.
    if (list.status == "published")
      list.update_columns(:organization_id => nil, status: List.statuses[:draft])
    else
      user = User.find(list.user_id)
      list.update_columns(:organization_id => user.organization_id, status: List.statuses[:published])
    end
    list.reindex
    redirect_to :action => "lists"
  end
 
  def audios_upload_new
    flash[:errors] = {}
    if params[:upload][:story].blank?
      flash[:errors]["Story URL"] = "Can not be blank"
    else
      begin
        @story = Story.find(params[:upload][:story].split('/').last)
      rescue => e
       flash[:errors]["Story"] = "Not found with the given URL"
      end
    end
  end

  def audios_upload
    story = Story.find(params[:upload_audios][:story_id])
    if !params[:upload_audios][:mp3] && !params[:upload_audios][:preface_mp3] && !params[:upload_audios][:csv]
        flash[:notice] = "There is nothing to update"
        redirect_to :draft_audio_stories
    elsif (params[:upload_audios][:mp3] || params[:upload_audios][:preface_mp3] || params[:upload_audios][:csv])
      if !story.is_audio && !params[:upload_audios][:mp3] && !params[:upload_audios][:preface_mp3]
        flash[:errors] = "Audio and Attribution Audio files are mandatory for first creation of ReadAlong"
        redirect_to :draft_audio_stories
      else
        #Create a temp directory for each upload
        tmp_dir = Dir.mktmpdir(nil, Settings.audio_upload.base_dir)
        Rails.logger.info tmp_dir
        audio_file_path = File.join(tmp_dir, "#{story.to_param}.mp3")
        csv_file_path = File.join(tmp_dir, "#{story.to_param}.csv")
        cover_file_path = File.join(tmp_dir, "cover_#{story.to_param}.mp3")
        File.open(audio_file_path, "wb") { |f| f.write(params[:upload_audios][:mp3].read) } if params[:upload_audios][:mp3]
        File.open(csv_file_path, "wb") { |f| f.write(params[:upload_audios][:csv].read) } if params[:upload_audios][:csv]
        File.open(cover_file_path, "wb") { |f| f.write(params[:upload_audios][:preface_mp3].read) } if params[:upload_audios][:preface_mp3]
        audio_uploader = AudioUpload::AudioUploader.new
        audio_uploader.upload(story, tmp_dir)
        flash[:notice] = "ReadAlong story saved to drafts. Kindly click Publish to publish  the ReadAlong story"
        redirect_to :draft_audio_stories
      end
    end
  end

  def make_video
    story = Story.find(params[:id])
    if story.video_processing?
      flash[:notice] = 'Video is already processing'
    else
      story.is_video = true
      story.video_status = Story.video_statuses[:video_processing]
      story.save!
      Delayed::Job.enqueue Jobs::ProcessVideoJob.new(story, current_user)
      flash[:notice] = 'Video will be generated soon'
    end
    redirect_to :published_audio_stories
  end

  def draft_video_stories
    @current_tab = "draft_video_stories"
    @stories = Story.where(is_video: true, video_status: 1)
  end
 
  def published_video_stories
    @current_tab = "published_video_stories"
    @stories = Story.where(is_video: true, video_status: 2)
  end

  def publish_video_story
    story = Story.find_by_id(params[:id])
    `python #{Rails.root}/lib/youtube_apis/update_video.py --video_id="#{story.youtube_link}" --privacyStatus="Public" --language="#{story.language.name.downcase}"`
    story.video_status = Story.video_statuses[:video_published]
    story.save!
    flash[:notice] = "Video has been published successfully"
    redirect_to :published_video_stories
  end

  def get_video_file
    story = Story.find(params[:id])
    if Rails.env.production?
      credentials =  YAML.load_file("#{Rails.root}/config/fog.yml")
      connection = Fog::Storage.new(credentials.values.first.symbolize_keys!)
      directory = connection.directories.get(Settings.fog.directory)
      head(:not_found) and return if story.nil?
      file = directory.files.get("stories/#{story.id}/videos/#{story.to_param}.mp4").public_url
      Rails.logger.info file
      filename = "#{story.to_param}.mp4"
      data = open(file)
      send_data data.read, :filename=>filename, :dispostion=>'inline', :stream => true
    else
      head(:not_found) and return if story.nil?
        file_path = "#{Rails.root}/public/#{Settings.fog.directory}/stories/#{story.id}"
        send_file "#{file_path}/videos/#{story.to_param}.mp4", :filename=>"#{story.to_param}.mp4", :dispostion=>'inline'
    end

  end

  def delete_video
    story = Story.find(params[:id])
    `python #{Rails.root}/lib/youtube_apis/delete_video.py --video_id="#{story.youtube_link}" --language="#{story.language.name.downcase}"`
    story.video_status = nil
    story.is_video = false
    story.youtube_link = nil
    story.save!
    flash[:notice] = "Video has been deleted successfully"
    redirect_to :draft_video_stories
  end

  def draft_audio_stories
   @current_tab = "draft_audio_stories"
   @stories = Story.where(is_audio: true, audio_status: "audio_draft")
  end
 
  def published_audio_stories
   @current_tab = "published_audio_stories"
   @stories = Story.where(status: 1, is_audio: true, audio_status: 1)
  end
 
  def get_sls_file
    story = Story.find(params[:id])
    if Rails.env.production?
      credentials =  YAML.load_file("#{Rails.root}/config/fog.yml")
      connection = Fog::Storage.new(credentials.values.first.symbolize_keys!)
      directory = connection.directories.get(Settings.fog.directory)
      head(:not_found) and return if story.nil?
      file = params[:format] == "csv" ? directory.files.get("stories/#{story.id}/csv/#{story.to_param}.csv").public_url : directory.files.get("stories/#{story.id}/vtt/story/#{story.to_param}.vtt").public_url
      Rails.logger.info file
      filename = "#{story.to_param}.#{params[:format] == "csv" ? 'csv' : 'vtt'}"
      data = open(file)
      send_data data.read, :filename=>filename, :dispostion=>'inline', :stream => true
    else
      head(:not_found) and return if story.nil?
        file_path = "#{Rails.root}/public/#{Settings.fog.directory}/stories/#{story.id}"
        format = "#{params[:format] == "csv" ? 'csv' : 'vtt'}"
        send_file "#{file_path}/#{params[:format] == "csv" ? 'csv' : 'vtt/story'}/#{story.to_param}.#{format}", :filename=>"#{story.to_param}.#{format}", :dispostion=>'inline'
    end
  end

  def delete_audio
    story = Story.find(params[:id])
    story.audio_status = Story.audio_statuses[:audio_draft]
    story.video_status = nil
    story.is_video = false
    unless story.youtube_link.nil?
      `python #{Rails.root}/lib/youtube_apis/delete_video.py --video_id="#{story.youtube_link}" --language="#{story.language.name.downcase}"`
      story.youtube_link = nil
    end
    story.save!
    flash[:notice] = "Audio has been deleted successfully"
    redirect_to :draft_audio_stories
  end

  def all_illustrations
    @current_tab = "all_illustrations"
    @illustrations = Illustration.where("created_at >= ?", 1.month.ago) if params[:search_from] == "One Month"
    @illustrations = Illustration.where("created_at >= ?", 3.month.ago) if params[:search_from] == "Three Months"
    @illustrations = Illustration.where("created_at >= ?", 6.month.ago) if params[:search_from] == "Six Months"
    @illustrations = Illustration.where("created_at >= ?", 1.year.ago) if params[:search_from] == "One Year"
    @illustrations = Illustration.all if params[:search_from] == "All Illustrations"
    @illustrations = Illustration.where("created_at >= ? and created_at <= ?", params[:start_date], params[:end_date]) if params[:start_date].present? && params[:end_date].present?
  end

  def images_upload
    if params[:upload_images] && params[:upload_images][:csv] && params[:upload_images][:zip]
      csv_name = params[:upload_images][:csv].original_filename
      zip_name = params[:upload_images][:zip].original_filename
      #Create a temp directory for each upload
      tmp_dir = Dir.mktmpdir(nil, Settings.image_upload.base_dir)
      Rails.logger.info tmp_dir
      csv_path = File.join(tmp_dir, csv_name)
      zip_path = File.join(tmp_dir, zip_name)
      File.open(csv_path, "wb") { |f| f.write(params[:upload_images][:csv].read) }
      File.open(zip_path, "wb") { |f| f.write(params[:upload_images][:zip].read) }
      #Extract images form the zip file
      results = extract_images_from_zip(tmp_dir, zip_path)
      if results[:error].nil?
        image_uploader = ImageUpload::Uploader.new
        results =
          begin
           image_uploader.upload(csv_name, tmp_dir)
          rescue => e
            [e]
          end
        if results.any?
          flash[:error] = results.join(", ")
        else
          flash[:notice] = "Images uploaded successfully"
        end
      else
        flash[:error] = results[:error]
      end
      FileUtils.rm_rf(tmp_dir)
    else
      flash[:error]="Please upload csv and images zip file"
    end
    redirect_to "/v0/dashboard/images_upload_new"
  end

  def extract_images_from_zip(dir, path)
    Zip::ZipFile.open(path) { |zip_file|
      zip_file.each { |f|
        #check zip content has image file or directory
        if f.file?
          f_path=File.join(dir, f.name)
          zip_file.extract(f, f_path) unless File.exist?(f_path)
        else
          return {error: "Unable to find image file in zip directory"}
        end
      }
    }
  end

  def roles
    @current_tab = "roles"
    @users = User.where.not(:organization_id => nil).reorder("created_at DESC")
  end

  def set_role
    get_email = params[:user][:user_email].split(',').first
    @user = User.find_by_email(get_email)
    
    flash[:errors] = {}

    #params[:user][:role] == "publisher"  || params[:user][:role] == "translator" ? params[:user].merge!(type: params[:user][:role] == "publisher" ? "Publisher" : "Translator") : params[:user].merge!(type: "User")
    params[:user].merge!(type: "User")
    if @user && !params[:user][:role].blank?
      if @user.update_attributes(:site_roles => @user.update_site_role(params[:user][:role]), type: params[:user][:type])
        flash[:notice] = "#{@user.name} has been assigned the role of a #{params[:user][:role].titleize} successfully "
      else
        flash[:errors] = @user.errors.messages
      end
    else
      flash[:errors][:email] = "can't be blank" if params[:user][:user_email].blank?
      flash[:errors][:role] = "can't be blank" if params[:user][:role].blank?
      flash[:errors][:user] = "not found" if @user.blank? && !params[:user][:user_email].blank?
    end

    redirect_to roles_path
  end

  def remove_site_role_dialog
    @user = User.find_by_id(params[:user_id])
    @role = params[:role]
    @site_role = params[:site_role]
  end

  def remove_site_role
    user = User.find_by_id(params[:user_id])
    roles = user.site_roles.split(",")
    user.site_roles = remove_roles(roles, params[:role])
    user.save!
    respond_to do |format|
      format.js{ render js: "window.location = '#{roles_path}';" }
    end
    flash[:notice] = user.first_name+" is successfully removed as "+ params[:role]
  end

  def remove_roles(user_roles, remove_role)
    if user_roles.length > 1
      user_roles.delete(remove_role)
      return user_roles.join(",")
    else
      user_roles.delete(params[:role])
      return nil
    end
  end

  def un_reviewed_stories
    @current_tab = "un_reviewed_stories"
    @stories = Story.search('*', where: { status: "published", reviewer_comment: false, is_flagged: false, organization: ""}, limit: 10000, order: {published_at: "asc"}, load: false)
  end

  def un_translated_stories
    @current_tab = "un_translated_stories"
    @stories = Story.where(:is_autoTranslate => true, :status => Story.statuses[:draft],:started_translation_at => nil)
                    .uniq
  end

  def translate_stories
    @current_tab = "translate_stories"
    language_id = Language.find_by_name("English").id
    params[:language] = language_id
    @stories = Story.where("status = ? AND organization_id IS NOT NULL AND language_id = ?", Story.statuses[:published], language_id).uniq
  end

  def translated_stories
    @current_tab = "translated_stories"
    @stories = Story.where(:status => Story.statuses[:published], :is_autoTranslate => true)
                    .uniq
  end

  def translation_drafts
    @current_tab = "translation_drafts"
    @stories = Story.where(:is_autoTranslate => true, :status => Story.statuses[:draft])
                    .where.not(:started_translation_at => nil)
                    .reorder("started_translation_at DESC")
  end

  def reviewed_stories
    @current_tab = "reviewed_stories"
    @stories = Story.search('*', where: { status: "published", reviewer_comment: true, is_flagged: false, organization: ""}, limit: 10000, order: {published_at: "desc"}, load: false)
  end

  def get_language_stories
    conditions = { status: "published", is_flagged: false, organization: "" }

    conditions[:language] = params[:language] if params[:language].present?
    conditions[:reading_level] = params[:level].to_i + 1 if params[:level].present?

    @story_type = params[:story_type] == "Original" ? nil : (params[:story_type] == "Translation" ? "translated" : "relevelled") if params[:story_type] && params[:story_type] != ''
    conditions[:derivation_type] = @story_type if params[:story_type] && params[:story_type] != ''
    if params[:current_tab] == "un_reviewed_stories"
      @current_tab = 'un_reviewed_stories'
      conditions[:reviewer_comment] = false
      @stories = Story.search('*', where: conditions, limit: 10000, order: {published_at: "desc"}, load: false)
    else
      @current_tab = "reviewed_stories"
      conditions[:reviewer_comment] = true
      @stories = Story.search('*', where: conditions, limit: 10000, order: {published_at: "desc"}, load: false)
    end 
    @page = "language_stories" 
  end

  def get_tlanguage_stories
    conditions = {:flaggings_count => nil}
    @language =  Language.find_by_name(params[:language]) if params[:language] && params[:language] != ''
    conditions[:language] = @language if @language
    conditions[:reading_level] = params[:level] if params[:level] && params[:level] != ''
    if params[:current_tab] == "un_translated_stories"
      @current_tab = 'un_translated_stories'
      @stories = Story.joins(:authors)
                      .where(:is_autoTranslate => true, :status => Story.statuses[:draft], :started_translation_at => nil)
                      .where(conditions)
                      .uniq
    else
      @current_tab = "translated_stories"
      @stories = Story.joins(:authors)
                      .where(:is_autoTranslate => true,:status => Story.statuses[:published] )
                      .where(conditions)
                      .uniq
    end 
    @page = "tlanguage_stories" 
  end

  def get_tlanguage_stories_new
    conditions = {
      status: "published",
      organization: { not: "" }
    }


    if params[:language].present?
      language = Language.find_by_id(params[:language])
      if language.present?
        conditions[:language] = language.name
      end
    end

    if params[:level].present?
      conditions[:reading_level] = params[:level].to_i + 1
    end

    if params[:publisher].present?
      publisher = Organization.find_by_id(params[:publisher])
      if publisher.present?
        conditions[:organization] = publisher.organization_name
      end
    end

    if params[:translate_language].present?

      # 
      # Filter stories list if the target language translation for the story is already present
      #
      language_name = Language.find_by_id(params[:translate_language])
      if(language_name.present?)
        conditions[:target_language] =  { not: language_name.name }
      end
    end

    #stories = Story
    #if params[:translator].present?
    #  stories = stories.joins(translator_stories: :translator)
    #  condition[:"users.organization_id"] = params[:translator]
    #end

    if params[:category].present?
      category = StoryCategory.find_by_id(params[:category])
      if category.present?
        conditions[:categories] = category.name
      end
    end

    @current_tab = "translate_stories"

    # ES default limit count is 1000, to increase the limit count override the limit by passing it to search
    # TODO Fix for limit
    @stories = Story.search(where: conditions, :limit => 10000).records
  end

  def assign_stories_translator
    begin
      if(params[:user_email].empty? || params[:story_ids].empty? || params[:translate_language].empty?)
        render :json => {}, status: :unprocessible_entity
      end
  
      user = User.find_by_email(params[:user_email])
      translate_language = Language.find_by_id(params[:translate_language])
      if !user
        render :json => {:errors => "User not present"}, status: :not_found 
      elsif !translate_language
        render :json => {:errors => "Language not present"}, status: :not_found
      else
        if !user.tlanguages.find_by_id( translate_language.id)
          user.tlanguages << translate_language
        end
          
        # Get stories already present for the destination language
        translator_story_ids = TranslatorStory.where(:story_id => params[:story_ids], :translate_language_id => translate_language.id).pluck(:story_id)
        story_ids = params[:story_ids].map(&:to_i) - translator_story_ids

        date_now = Date.today

        new_translator_stories = story_ids.map do |story_id|
          {
            :story_id => story_id,
            :translate_language_id => translate_language.id,
            :translator_id => user.id,
            :translator_organization_id => user.organization_id,
            :start_date => date_now
          } 
        end

        # Create Translator Stories which are not present
        TranslatorStory.create!(new_translator_stories)

        # Update the translator for existing story with destination language
        translator_stories = TranslatorStory.where(:story_id => translator_story_ids, :translate_language_id => translate_language.id)
        # Move previous translated drafts from translator organization to storyweaver organization
        target_story_ids = translator_stories.pluck(:translator_story_id)
        update_target_stories = Story.where(:id => target_story_ids).update_all(:organization_id => nil)

        update_translator_stories = translator_stories.update_all(:translator_id => user.id, :translator_story_id => nil, :translator_organization_id => user.organization_id, :start_date => date_now)
        
        if(update_translator_stories && update_target_stories)
          render :json => {}, status: :ok
        else
          render :json => {}, status: :unprocessible_entity
        end
      end
    rescue Exception => e
      render :json => {}, status: :unprocessible_entity
    end
  end

  def reviewer_summary
    @current_tab = "reviewer_summary"
    conditions = {:status => Story.statuses[:published], :flaggings_count => nil, :organization_id => nil}
    @un_reviewed_count = Story.joins("LEFT OUTER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                      .where("reviewer_comments.story_id IS ?", nil)
                      .where(conditions).reorder("published_at ASC").count
    @language =  Language.all
    @hash ={}
    @language.each do |language|
      conditions[:language] = language
       stories_count = Story.joins("LEFT OUTER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                      .where("reviewer_comments.story_id IS ?", nil)
                      .where(conditions).reorder("published_at ASC")
      @hash[language.name] = stories_count.count
    end
  end

  def reviewer_analytics
    @current_tab = "reviewer_analytics"
    @languages = Language.all
    if params[:language] && params[:language] != ""
      conditions = {:status => Story.statuses[:published], :flaggings_count => nil, :organization_id => nil}
      @language = Language.find_by_name(params[:language]) if params[:language].present? 
      conditions[:language] = @language if @language
      @language_stories = if  params[:group] == "month"
                          language_reviewer_month = Story.joins("INNER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                                                         .where(conditions)
                                                         .group_by_month("reviewer_comments.created_at").reorder("month asc").count


                          language_un_reviewers_month = Story.where(conditions).group_by_month("stories.published_at").reorder("month asc").count                                                       

                          newly_added =   get_un_reviewed([language_un_reviewers_month,language_reviewer_month])


                          reviewers_assigned = User.joins("INNER JOIN reviewers_languages ON users.id = reviewers_languages.user_id")
                                                    .where("reviewers_languages.language_id=?",@language).uniq
                                                    .group_by_month("reviewers_languages.created_at")
                                                    .reorder("month asc").count

                          active_users = User.joins("INNER JOIN reviewer_comments ON users.id = reviewer_comments.user_id")
                                             .where("reviewer_comments.language_id =?",@language).uniq
                                             .group_by_month("reviewer_comments.created_at").reorder("month asc").count                                  

                          [{name: 'Stories to Rate', data: language_un_reviewers_month.to_a.reverse.to_h, type: 'Month'}]+
                          [{name: 'Rated Stories', data: language_reviewer_month.to_a.reverse.to_h.to_a.reverse.to_h}]+
                          [{data: newly_added.to_a.reverse.to_h}]+[{data: reviewers_assigned.to_a.reverse.to_h}]+
                          [{data: active_users.to_a.reverse.to_h}]
                         else
                          language_reviewer_week = Story.joins("INNER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                                                        .where(conditions)
                                                        .group_by_week("reviewer_comments.created_at").reorder("week asc").count


                          language_un_reviewer_week = Story.where(conditions).group_by_week("stories.published_at").reorder("week asc").count

                          newly_added =   get_un_reviewed([language_un_reviewer_week,language_reviewer_week])

                          reviewers_assigned = User.joins("INNER JOIN reviewers_languages ON users.id = reviewers_languages.user_id")
                                                    .where("reviewers_languages.language_id=?",@language).uniq
                                                    .group_by_week("reviewers_languages.created_at")
                                                    .reorder("week asc").count

                          active_users = User.joins("INNER JOIN reviewer_comments ON users.id = reviewer_comments.user_id")
                                             .where("reviewer_comments.language_id =?",@language).uniq
                                             .group_by_week("reviewer_comments.created_at").reorder("week asc").count


                          [{name: 'Stories to Rate', data: language_un_reviewer_week.to_a.reverse.to_h, type: 'Week'}]+
                          [{name: 'Rated Stories', data: language_reviewer_week.to_a.reverse.to_h}]+
                          [{data: newly_added.to_a.reverse.to_h}]+[{data: reviewers_assigned.to_a.reverse.to_h}]+
                          [{data: active_users.to_a.reverse.to_h}]
                         end
        @un_reviewed_count = Story.joins("LEFT OUTER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                      .where("reviewer_comments.story_id IS ?", nil)
                      .where(conditions).reorder("published_at ASC").count
        @reviewed_count = Story.joins("INNER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                      .where(conditions).reorder("published_at DESC").count
     else                                                                                                              
      @stories = if  params[:group] == "month"
                    reviewed_stories_month = Story.joins("INNER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                                                  .where(:status => Story.statuses[:published], :organization_id => nil, :flaggings_count => nil)
                                                  .group_by_month("reviewer_comments.created_at").reorder("month asc").count


                    unreviewed_stories_month =   Story.where(:status => Story.statuses[:published], :organization_id => nil, :flaggings_count => nil)  
                                                      .group_by_month("stories.published_at").reorder("month asc").count

                    newly_added =   get_un_reviewed([unreviewed_stories_month,reviewed_stories_month])

                    reviewers_assigned = User.joins("INNER JOIN reviewers_languages ON users.id = reviewers_languages.user_id").uniq
                                             .group_by_month("reviewers_languages.created_at")
                                             .reorder("month asc").count

                    active_users = User.joins("INNER JOIN reviewer_comments ON users.id = reviewer_comments.user_id")
                                       .uniq.group_by_month("reviewer_comments.created_at").reorder("month asc").count

                    [{name: 'Stories to Rate', data: unreviewed_stories_month.to_a.reverse.to_h, type: 'Month'}]+
                    [{name: 'Rated Stories', data: reviewed_stories_month.to_a.reverse.to_h}]+
                    [{data: newly_added.to_a.reverse.to_h}]+[{data: reviewers_assigned.to_a.reverse.to_h}]+
                    [{data: active_users.to_a.reverse.to_h}]

                 else
                    reviewed_stories_week = Story.joins("INNER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                                                 .where(:status => Story.statuses[:published], :organization_id => nil, :flaggings_count => nil)
                                                 .group_by_week("reviewer_comments.created_at").reorder("week asc").count
                                

                    unreviewed_stories_week = Story.where(:status => Story.statuses[:published], :organization_id => nil, :flaggings_count => nil)
                                                   .group_by_week("stories.published_at").reorder("week asc").count
                                                   
                    newly_added =   get_un_reviewed([unreviewed_stories_week,reviewed_stories_week])

                    reviewers_assigned = User.joins("INNER JOIN reviewers_languages ON users.id = reviewers_languages.user_id").uniq
                                             .group_by_week("reviewers_languages.created_at")
                                             .reorder("week asc").count

                    active_users = User.joins("INNER JOIN reviewer_comments ON users.id = reviewer_comments.user_id")
                                       .uniq.group_by_week("reviewer_comments.created_at").reorder("week asc").count

                    

                    [{name: 'Stories to Rate', data: unreviewed_stories_week.to_a.reverse.to_h, type: 'Week'}]+
                    [{name: 'Rated Stories', data: reviewed_stories_week.to_a.reverse.to_h}]+
                    [{data: newly_added.to_a.reverse.to_h}]+[{data: reviewers_assigned.to_a.reverse.to_h}]+
                    [{data: active_users.to_a.reverse.to_h}]
                 end
      @un_reviewed_story_count = Story.joins("LEFT OUTER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                    .where("reviewer_comments.story_id IS ?", nil)
                    .where(:status => Story.statuses[:published], :organization_id => nil, :flaggings_count => nil)
                    .reorder("published_at ASC").count
      @reviewed_stories_count = Story.joins("INNER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                                   .where(:status => Story.statuses[:published], :organization_id => nil, :flaggings_count => nil)
                                   .reorder("published_at DESC").count
     end
  end

  def translator_analytics
    @current_tab = "translator_analytics"
    @languages = Language.all
    if params[:language] && params[:language] != ""
      conditions = {:flaggings_count => nil}
      @language = Language.find_by_name(params[:language]) if params[:language].present? 
      conditions[:language] = @language if @language
      @language_stories = if  params[:group] == "month"
                          language_translator_month = Story.where(:status => Story.statuses[:published], :is_autoTranslate => true, :flaggings_count => nil)
                                                         .where(conditions)
                                                         .group_by_month("stories.published_at").reorder("month asc").count


                          language_un_translator_month = Story.where(:status => Story.statuses[:draft], :is_autoTranslate => true, :flaggings_count => nil)
                                                             .where(:started_translation_at =>nil)    
                                                             .where(conditions)
                                                             .group_by_month("stories.published_at")
                                                             .reorder("month asc").count
                          
                          language_in_draft_month     = Story.where(:status => Story.statuses[:draft], :is_autoTranslate => true, :flaggings_count => nil)
                                                      .where.not(:started_translation_at => nil)  
                                                      .where(conditions)
                                                      .group_by_month("stories.created_at")
                                                      .reorder("month asc").count

                          translators_assigned = User.joins("INNER JOIN translators_languages ON users.id = translators_languages.user_id")
                                                   .where("translators_languages.language_id=?",@language).uniq
                                                   .group_by_month("translators_languages.created_at")
                                                   .reorder("month asc").count

                          assigned_during_month  = User.joins("INNER JOIN translators_languages ON users.id = translators_languages.user_id")
                                                       .where("translators_languages.language_id=?",@language).uniq
                                                       .group_by_month("translators_languages.created_at")
                                                       .reorder("month asc").count                                  

                          [{name: 'Un Translated Stories', data: language_un_translator_month.to_a.reverse.to_h, type: 'Month'}]+
                          [{name: 'Translated Stories', data: language_translator_month.to_a.reverse.to_h}]+
                          [{name: 'In progress Stories', data: language_in_draft_month.to_a.reverse.to_h}]+
                          [{data: translators_assigned.to_a.reverse.to_h}]+[{data: assigned_during_month.to_a.reverse.to_h}]

                         else
                          language_translator_week = Story.where(:status => Story.statuses[:published], :is_autoTranslate => true, :flaggings_count => nil)
                                                        .where(conditions)
                                                        .group_by_week("stories.published_at").reorder("week asc").count


                          language_un_translator_week = Story.where(:status => Story.statuses[:draft], :is_autoTranslate => true, :flaggings_count => nil)
                                                           .where(conditions)
                                                           .group_by_week("stories.published_at")
                                                           .reorder("week asc").count

                          language_in_draft_week   = Story.where(:status => Story.statuses[:draft], :is_autoTranslate => true, :flaggings_count => nil)
                                                   .where.not(:started_translation_at => nil)
                                                   .where(conditions)
                                                   .group_by_week("stories.published_at").reorder("week asc").count                                 


                          translators_assigned = User.joins("INNER JOIN translators_languages ON users.id = translators_languages.user_id")
                                                    .where("translators_languages.language_id=?",@language).uniq
                                                    .group_by_week("translators_languages.created_at")
                                                    .reorder("week asc").count

                          assigned_during_week = User.joins("INNER JOIN translators_languages ON users.id = translators_languages.user_id")
                                                     .where("translators_languages.language_id=?",@language).uniq
                                                     .group_by_week("translators_languages.created_at")
                                                     .reorder("week asc").count


                          [{name: 'Un Translated Stories', data: language_un_translator_week.to_a.reverse.to_h, type: 'Week'}]+
                          [{name: 'Translated Stories', data: language_translator_week.to_a.reverse.to_h}]+
                          [{name: 'In progress Stories', data: language_in_draft_week.to_a.reverse.to_h}]+
                          [{data: translators_assigned.to_a.reverse.to_h}]+[{data: assigned_during_week.to_a.reverse.to_h}]
                         end

        @un_translated_count = Story.where(:status => Story.statuses[:draft], :is_autoTranslate => true)
                                    .where(:started_translation_at =>nil)
                                    .where(conditions)
                                    .count
        @translated_count    = Story.where(:status => Story.statuses[:published], :is_autoTranslate => true)
                                    .where(conditions)
                                    .count
        @in_draft_count      = Story.where(:status => Story.statuses[:draft], :is_autoTranslate => true)
                                    .where.not(:started_translation_at =>nil)
                                    .where(conditions)
                                    .count 
        @analytics_keys = translator_analytics_keys(@language_stories)                                                      
     else                                                                                                              
      @stories = if  params[:group] == "month"
                    translated_stories_month   = Story.where(:status => Story.statuses[:published], :is_autoTranslate => true, :flaggings_count => nil)
                                                      .group_by_month("stories.published_at").reorder("month asc").count


                    untranslated_stories_month = Story.where(:status => Story.statuses[:draft], :is_autoTranslate => true, :flaggings_count => nil)
                                                      .where(:started_translation_at => nil)  
                                                      .group_by_month("stories.created_at").reorder("month asc").count

                    in_draft_stories_month     = Story.where(:status => Story.statuses[:draft], :is_autoTranslate => true, :flaggings_count => nil)
                                                      .where.not(:started_translation_at => nil)  
                                                      .group_by_month("stories.created_at").reorder("month asc").count 

                    translators_assigned = User.joins("INNER JOIN translators_languages ON users.id = translators_languages.user_id").uniq
                                               .group_by_month("translators_languages.created_at")
                                               .reorder("month asc").count

                    assigned_during_month = User.joins("INNER JOIN translators_languages ON users.id = translators_languages.user_id").uniq
                                                .group_by_month("translators_languages.created_at")
                                                .reorder("month asc").count

                    [{name: 'Un Translated Stories', data: untranslated_stories_month.to_a.reverse.to_h, type: 'Month'}]+
                    [{name: 'Translated Stories', data: translated_stories_month.to_a.reverse.to_h}]+
                    [{name: 'In progress Stories', data: in_draft_stories_month.to_a.reverse.to_h}]+
                    [{data: translators_assigned.to_a.reverse.to_h}]+[{data: assigned_during_month.to_a.reverse.to_h.to_a.reverse.to_h}]
                 else
                    translated_stories_week = Story.where(:status => Story.statuses[:published], :is_autoTranslate => true, :flaggings_count => nil)
                                                   .group_by_week("stories.published_at").reorder("week asc").count
                                

                    untranslated_stories_week = Story.where(:status => Story.statuses[:draft], :is_autoTranslate => true, :flaggings_count => nil)
                                                   .where(:started_translation_at => nil)
                                                   .group_by_week("stories.published_at").reorder("week asc").count

                    in_draft_stories_week   = Story.where(:status => Story.statuses[:draft], :is_autoTranslate => true, :flaggings_count => nil)
                                                   .where.not(:started_translation_at => nil)
                                                   .group_by_week("stories.published_at").reorder("week asc").count                               

                    translators_assigned = User.joins("INNER JOIN translators_languages ON users.id = translators_languages.user_id").uniq
                                             .group_by_week("translators_languages.created_at")
                                             .reorder("week asc").count
                                             
                    assigned_during_week = User.joins("INNER JOIN translators_languages ON users.id = translators_languages.user_id").uniq
                                               .group_by_week("translators_languages.created_at")
                                               .reorder("week asc").count

                    

                    [{name: 'Un Translated Stories', data: untranslated_stories_week.to_a.reverse.to_h, type: 'Week'}]+
                    [{name: 'Translated Stories', data: translated_stories_week.to_a.reverse.to_h}]+
                    [{name: 'In progress Stories', data: in_draft_stories_week.to_a.reverse.to_h}]+
                    [{data: translators_assigned.to_a.reverse.to_h}]+
                    [{data: assigned_during_week.to_a.reverse.to_h}]
                 end

      @un_translated_story_count = Story.where(:status => Story.statuses[:draft], :is_autoTranslate => true)
                                        .where(:started_translation_at =>nil)
                                        .count
      @translated_stories_count  = Story.where(:status => Story.statuses[:published], :is_autoTranslate => true)
                                        .count
      @in_draft_stories_count    = Story.where(:status => Story.statuses[:draft], :is_autoTranslate => true)
                                        .where.not(:started_translation_at =>nil)
                                        .count
      @analytics_keys = translator_analytics_keys(@stories)                                                                    
     end
  end

 

 def translator_analytics_keys(stories)
  (stories[0][:data].keys+stories[1][:data].keys+stories[2][:data].keys+
    stories[3][:data].keys+stories[4][:data].keys).uniq
 end
 
 def translator_analytics_language_keys
  (language_stories[0][:data].keys+language_stories[1][:data].keys+language_stories[2][:data].keys+
    language_stories[3][:data].keys+language_stories[4][:data].keys+language_stories[5][:data].keys).uniq
 end


 def get_un_reviewed(record)
  sum = 0;
  hash = { }
  (record[0].keys+record[1].keys).uniq.each do|key|
    sum = ((record[0][key].nil? ? 0 : record[0][key]+sum) - (record[1][key].nil? ? 0 : record[1][key]))
    hash[key] = sum
  end
  return hash
 end

  def assign_reviewer
    @current_tab = "assign_reviewer"
    if(params[:query] == "language")
      @language_reviewers = Language.joins(:reviewers).where("reviewers_languages.language_id IS NOT ?",nil).reorder(:name).uniq
      @sort_value = params[:query]
   else
      @language_reviewers = User.joins(:languages).where("reviewers_languages.user_id IS NOT ?",nil).reorder(:first_name, :last_name).uniq
      @sort_value = params[:query]
      respond_to do |format|
        format.html
        format.js { }
      end
    end 
  end

  def assign_translator
    @current_tab = "assign_translator"
    if(params[:query] == "language")
      @language_translators = Language.joins(:translators).where("translators_languages.language_id IS NOT ?",nil).reorder(:name).uniq
      @sort_value = params[:query]
    else
      @language_translators = User.joins(:tlanguages).where("translators_languages.user_id IS NOT ?",nil).reorder(:first_name, :last_name).uniq
      @sort_value = params[:query]
      respond_to do |format|
        format.html
        format.js { }
      end
    end 
  end


  def delete_language_reviewer_dialog
    @user = User.find_by_id(params[:reviewer_id]) if params[:reviewer_id].present?
    @language = Language.find_by_id(params[:language_id]) if params[:language_id].present?
  end

  def delete_language_reviewer
    @user = User.find_by_id(params[:reviewer_id]) if params[:reviewer_id].present?
    @language = Language.find_by_id(params[:language_id]) if params[:language_id].present?
    @reviewers_languages = @language.reviewers.find_by_id(@user)
    if @reviewers_languages
      @language.reviewers.delete(@user)
      flash[:notice] = @user.name+" has been removed as reviewer role for "+@language.name+" language."
      respond_to do |format|
        format.html
        format.js {render js: "window.location = '#{assign_reviewer_path}';"}
      end
    else
      flash[:notice] = "User not found"
      respond_to do |format|
        format.html
        format.js {render js: "window.location = '#{assign_reviewer_path}';"}
      end
    end
  end

  def delete_language_translator_dialog
    @user = User.find_by_id(params[:translator_id]) if params[:translator_id].present?
    @language = Language.find_by_id(params[:language_id]) if params[:language_id].present?
  end

  def delete_language_translator
    @user = User.find_by_id(params[:translator_id]) if params[:translator_id].present?
    @language = Language.find_by_id(params[:language_id]) if params[:language_id].present?
    @translators_languages = @language.translators.find_by_id(@user)
    if @translators_languages
      @language.translators.delete(@user)
      flash[:notice] = @user.name+" has been removed as translator role for "+@language.name+" language."
      respond_to do |format|
        format.html
        format.js {render js: "window.location = '#{assign_translator_path}';"}
      end
    else
        flash[:notice] = "User not found"
        respond_to do |format|
        format.html
        format.js {render js: "window.location = '#{assign_translator_path}';"}
      end
    end
  end

  def edit_review_form
    @story = Story.find_by_id(params[:id].to_i) if params[:id].present?
    @reviewer_comment = @story.reviewer_comment
    @rating = @reviewer_comment.rating
    @comments = Hash.new
    begin
      @comments = JSON.parse((@reviewer_comment.comments or ""))
    rescue JSON::ParserError => e
      Rails.logger.info "rating comment is not in JSON format"
    end
    @languages = Language.list_for_story_rating
    @reading_levels = Story::READING_LEVELS.keys
    @flag = true
  end

  def save_review_edit_form
    handle_extra_input(params[:reviewer_comment][:comments])
    params[:reviewer_comment][:comments].each {|k, v| v.delete("")}
    primary_comments = params[:reviewer_comment][:comments].keys
    @story = Story.find_by_id(params[:id])
    @reviewer_comment = ReviewerComment.find_by_story_id(params[:id])
    if is_there_flagging_comment(primary_comments)
      user = current_user
      comments = filter_flagging_comments(params[:reviewer_comment][:comments])
      reason = JSON.generate(comments)
      user.flag(@story, reason)
      @path = params[:type] if params[:type].present?
      content_managers = User.content_manager.collect(&:email).join(",")
      data_for_email = ReviewerComment.construct_comment_text(reason)
      UserMailer.delay(:queue => "mailer").flagged_story(content_managers, @story, user, data_for_email, @path)
      send_mail_if_level_mismatch(comments, @story)
      flash[:error] = "The story has been flagged. Thank you for drawing our attention to this story."
    end
      @reviewer_comment.user_id = current_user.id
      @reviewer_comment.rating = params[:reviewer_comment][:rating]
      @reviewer_comment.comments = JSON.generate(params[:reviewer_comment][:comments])
      if @reviewer_comment.save
        Story.find_by_id(params[:id]).reindex
        flash[:notice] = "Thank you for rating this story" if !@story.flagged?
      else
        flash[:error] = "Unable to save reviewer comment"
      end
    redirect_to reviewed_stroies_path
  end

  def assign_editor_modal
    @story = Story.find_by_id(params[:story_id]) if params[:story_id].present?
  end

  def delete_editor_modal
    @story = Story.find_by_id(params[:story_id]) if params[:story_id].present?
    @editor = User.find_by_id(@story.editor_id)
    @path = params[:path]
  end

  def delete_story_reviewer
    @story = Story.find_by_id(params[:story_id]) if params[:story_id].present?
    @user = User.find_by_id(params[:editor_id]) if params[:editor_id].present?
    if @story.editor_id == @user.id
      @story.update_attributes(:editor_id => nil)
      @story_details = Story.find_by_id(params[:story_id])
      flash[:notice] = @user.name+" has been removed as editor role for "+@story.title+" story."
        respond_to do |format|
          format.html
          if params[:path] == "story_details"
            format.js {render js: "window.location = '#{react_stories_show_path(@story.to_param)}';"}
          else
            format.js {render "assign_editor_to_uploaded_story"}
          end 
        end
    end    
  end

  #assign reviewer to legacy stories
  def assign_editor_to_uploaded_story
      @story = Story.find_by_id(params[:story_id]) if params[:story_id].present?
      @user = User.find_by_email(params[:editor_email].split(',').first)
      if @story.editor != @user
        if @story.update_attributes(:editor_id => @user.id)
          @story_details = Story.find_by_id(params[:story_id])
          respond_to do |format|
            format.html
            format.js 
          end
        end
      end
  end

  def private_images
    @current_tab = "private_images"
    @illustrations = Illustration.all.where(:image_mode => true).reorder("created_at DESC") 
  end

  #assigning reviewer to language
  def assign_language_reviewer
    if !params[:language][:email].blank? && !params[:language][:script].empty?
      @user = User.find_by_email(params[:language][:email].split(',').first) 
      if @user
        @language = Language.find(params[:language][:script]) 
        @reviewers_languages = @user.languages.find_by_id(@language)
        if @reviewers_languages
          flash[:errors] = "You have already assigned this reviewer to language"
          redirect_to assign_reviewer_path
        else
          @user.languages << @language
          flash[:notice] = @user.name+" has been assigned reviewer role successfully."
          redirect_to assign_reviewer_path
          UserMailer.delay(:queue=>"mailer").assign_language_reviewer(@user,@language.name)
        end
      else
        flash[:errors] = "User does not exist"
        redirect_to assign_reviewer_path
      end
    else
        redirect_to assign_reviewer_path
         flash[:errors] = "language can't be blank" if params[:language][:script].empty?
         flash[:errors] = "email can't be blank" if params[:language][:email].blank?
    end
  end

  def assign_language_translator
    if !params[:language][:email].blank? && !params[:language][:script].empty?
      @user = User.find_by_email(params[:language][:email].split(',').first)
      if @user
        @language = Language.find(params[:language][:script]) 
        @translators_languages = @user.tlanguages.find_by_id(@language)
        if @translators_languages
          flash[:errors] = "You have already assigned this translator to language"
          redirect_to assign_translator_path
        else
          @user.tlanguages << @language
          flash[:notice] = @user.name+" has been assigned translator role successfully."
          UserMailer.delay(:queue=>"mailer").assign_language_translator(@user,@language.name)
          redirect_to assign_translator_path
        end
      else
        flash[:errors] = "User does not exist"
        redirect_to assign_translator_path
      end
    else
        redirect_to assign_translator_path
         flash[:errors] = "language can't be blank" if params[:language][:script].empty?
         flash[:errors] = "email can't be blank" if params[:language][:email].blank?
    end
  end

  def process_search
    filters = filters()
    order_criteria = Story.count > 0 ? sort_params || DEFAULT_CRITERIA : []
    query = Story.search(
        @search_query_dashboard.present? ? params[:search][:query] : EVERYTHING,
        operator: "or",
        fields:['title^20', 'english_title^15', 'original_story_title^15',
                'organization^10', 'illustrators^10', 'authors^10', 'language^10',
                'other_credits^5', 'synopsis^5', 'content'],
        where: filters,
        order: order_criteria,
        load: false,
        execute: false)
    return query
  end 

  def filters
    filters = {}
    filters[:status] = [:uploaded]
    return filters
  end

  def sort_params
    sort = nil
      if params[:sort]
      sort = [
          {
            language: {order: params[:direction]=='asc' ? :asc : :desc}
          }
        ]
      end
    sort
  end

  def story_categories
    @current_tab = "story categories"
    @categories = StoryCategory.page(params[:page]).per(12)
  end

  def edit_story_category
    @category = StoryCategory.find_by_id(params[:id])

    flash[:errors] = {}

    if @category.update_attributes(:name => (params[:category][:name]).try(:strip), :private => to_boolean(params[:category][:private]))
      
    else
      flash[:errors] = @category.errors.messages
    end
      redirect_to story_categories_path
  end

  def to_boolean(str)
    str == "true"
  end

  def create_story_category
     flash[:errors] = {}
     
     @category = StoryCategory.new
     @category.name =  (params[:category][:name]).try(:strip)
     @category.translated_name = (params[:category][:name]).try(:strip)
     @category.private =  to_boolean(params[:category][:private])

     if @category.save
      translation = @category.translations.new
      translation.name = (params[:category][:name]).try(:strip)
      translation.translated_name = (params[:category][:translated_name]).try(:strip)
      translation.locale = "hi"
      translation.save!
     else
      flash[:errors] = @category.errors.messages
     end

     redirect_to story_categories_path
  end

  def illustration_categories
    @current_tab = "illustration categories"
    @categories = IllustrationCategory.page(params[:page]).per(12)
  end

  def edit_illustration_category
    @category = IllustrationCategory.find_by_id(params[:id])

    flash[:errors] = {}

    if @category.update_attributes(:name => (params[:category][:name]).try(:strip))
      
    else
      flash[:errors] = @category.errors.messages
    end
      redirect_to illustration_categories_path
  end

  def create_illustration_category
     flash[:errors] = {}
     
     @category = IllustrationCategory.new
     @category.name =  (params[:category][:name]).try(:strip)
     @category.translated_name = (params[:category][:name]).try(:strip)
     
     if @category.save
      translation = @category.translations.new
      translation.name = (params[:category][:name]).try(:strip)
      translation.translated_name = (params[:category][:translated_name]).try(:strip)
      translation.locale = "hi"
      translation.save!
     else
      flash[:errors] = @category.errors.messages
     end

     redirect_to illustration_categories_path
  end


  def languages
    @current_tab = "languages"
    @languages = Language.page(params[:page]).per(12)
    @scripts = LanguageFont.uniq.pluck(:script) # Getting the unique scripts form LangaugeFont table.
  end

  def create_language
     @language = Language.new
     @language.name =  (params[:language][:name]).try(:strip)
     @language.script = params[:language][:script]
     @language.script = @language.script.try(:downcase)
     @language.locale = "en"
     @language.bilingual = params[:language][:bilingual]
     @language.is_right_to_left = params[:language][:is_right_to_left]
     @language.language_font_id = LanguageFont.where(:script => @language.script).first.id if @language.script
     @language.translated_name = (params[:language][:name]).try(:strip)
     if @language.save
      translation = @language.translations.new
      translation.name = (params[:language][:name]).try(:strip)
      translation.translated_name = (params[:language][:translated_name]).try(:strip)
      translation.locale = "hi"
      translation.save!
     else
      flash[:errors] = @language.errors.messages
     end

     redirect_to languages_path
  end

  def donors
    @current_tab = "donors"
    @donors = Donor.page(params[:page]).per(12)
  end

  def create_donor
    @donor = Donor.new
    @donor.name =  (params[:donor][:name]).try(:strip)
    @donor.logo =  (params[:donor][:logo])


    if @donor.save

    else
      flash[:errors] = @donor.errors.messages
    end

    redirect_to donors_path
  end

  def delete_donor
    donor = Donor.find_by_id(params[:id])
    if donor.stories.present?   
       flash[:error]="Unable to delete this donor because it has stories"
       redirect_to donors_path
    else
      donor.destroy
      flash[:notice] = "Donor deleted successfully"
      redirect_to donors_path
    end
  end

  def styles
    @current_tab = "styles"
    @styles = IllustrationStyle.page(params[:page]).per(12)
  end

  def edit_style
    @style = IllustrationStyle.find_by_id(params[:id])

    flash[:errors] = {}

    if @style.update_attributes(:name => (params[:style][:name]).try(:strip))
      
    else
      flash[:errors] = @style.errors.messages
    end
      redirect_to styles_path

  end

  def analytics
    @current_tab = "graphs"
    @organizations = Organization.where(:organization_type => "Publisher").pluck(:organization_name)
    @organizations << 'Storyweaver community'
    if params[:stories]
      @stories = if params[:group]=="week"
                   Organization.where(:organization_type => "Publisher").map{|p| {name: p.organization_name, data: Story.where(:status => Story.statuses[:published]).where(:organization => p).group_by_week(:created_at).reorder("week desc").count}} +
                     [{name: 'Storyweaver community', data: Story.where(:status => Story.statuses[:published]).where(:organization => nil).group_by_week(:created_at).reorder("week desc").count}]
                 elsif  params[:group]=="month"
                   Organization.where(:organization_type => "Publisher").map{|p| {name: p.organization_name, data: Story.where(:status => Story.statuses[:published]).where(:organization => p).group_by_month(:created_at).reorder("month desc").count}} +
                     [{name: 'Storyweaver community', data: Story.where(:status => Story.statuses[:published]).where(:organization => nil).group_by_month(:created_at).reorder("month desc").count}]
                 elsif  params[:group]=="year"
                   Organization.where(:organization_type => "Publisher").map{|p| {name: p.organization_name, data: Story.where(:status => Story.statuses[:published]).where(:organization => p).group_by_year(:created_at).reorder("year desc").count}} +
                     [{name: 'Storyweaver community', data: Story.where(:status => Story.statuses[:published]).where(:organization => nil).group_by_year(:created_at).reorder("year desc").count}]
                 else
                   Organization.where(:organization_type => "Publisher").map{|p| {name: p.organization_name, data: Story.where(:status => Story.statuses[:published]).where(:organization => p).group_by_day(:created_at).reorder("day desc").count}} +
                     [{name: 'Storyweaver community', data: Story.where(:status => Story.statuses[:published]).where(:organization => nil).group_by_day(:created_at).reorder("day desc").count}]
                 end
      @story_count = Story.where(:status => Story.statuses[:published]).count
      @stories_table = {}
      @stories.each do |k|
        if k[:data].present?
          k[:data].each do |key, value|
            if @stories_table[key].blank?
              @stories_table[key] = {k[:name]=>value}
            else
              @stories_table[key] = @stories_table[key].merge({k[:name]=>value})
            end
          end
        end
      end



    elsif params[:original_stories]
      @original_stories =  if params[:group]=="week"
                              Organization.where(:organization_type => "Publisher").map{|p| {name: p.organization_name, data: Story.where(:status => Story.statuses[:published], :derivation_type => nil).where(:organization => p).group_by_week(:created_at, week_start: :mon).reorder("week desc").count}} +
                                 [{name: 'Storyweaver community', data: Story.where(:status => Story.statuses[:published], :derivation_type => nil).where(:organization => nil).group_by_week(:created_at, week_start: :mon).reorder("week desc").count}]
                            elsif params[:group]=="month"
                              Organization.where(:organization_type => "Publisher").map{|p| {name: p.organization_name, data: Story.where(:status => Story.statuses[:published], :derivation_type => nil).where(:organization => p).group_by_month(:created_at).reorder("month desc").count}} +
                                 [{name: 'Storyweaver community', data: Story.where(:status => Story.statuses[:published], :derivation_type => nil).where(:organization => nil).group_by_month(:created_at).reorder("month desc").count}]
                            elsif params[:group]=="year"
                              Organization.where(:organization_type => "Publisher").map{|p| {name: p.organization_name, data: Story.where(:status => Story.statuses[:published], :derivation_type => nil).where(:organization => p).group_by_year(:created_at).reorder("year desc").count}} +
                                 [{name: 'Storyweaver community', data: Story.where(:status => Story.statuses[:published], :derivation_type => nil).where(:organization => nil).group_by_year(:created_at).reorder("year desc").count}]
                            else
                              Organization.where(:organization_type => "Publisher").map{|p| {name: p.organization_name, data: Story.where(:status => Story.statuses[:published], :derivation_type => nil).where(:organization => p).group_by_day(:created_at).reorder("day desc").count}} +
                                 [{name: 'Storyweaver community', data: Story.where(:status => Story.statuses[:published], :derivation_type => nil).where(:organization => nil).group_by_day(:created_at).reorder("day desc").count}]
                            end

      @original_stories_table = {}
      @original_stories.each do |k|
        if k[:data].present?
          k[:data].each do |key, value|
            if @original_stories_table[key].blank?
              @original_stories_table[key] = {k[:name]=>value}
            else
              @original_stories_table[key] = @original_stories_table[key].merge({k[:name]=>value})
            end
          end
        end
      end
      @original_stories_count = Story.where(:status => Story.statuses[:published], :derivation_type => nil).count
    elsif params[:derivatives]
      @derivative_stories =  if params[:group]=="week"
                               Organization.where(:organization_type => "Publisher").map{|p| {name: p.organization_name, data: Story.where(:status => Story.statuses[:published]).where.not(:derivation_type => nil).where(:organization => p).group_by_week(:created_at, week_start: :mon).reorder("week desc").count}} +
                                 [{name: 'Storyweaver community', data: Story.where(:status => Story.statuses[:published]).where.not(:derivation_type => nil).where(:organization => nil).group_by_week(:created_at, week_start: :mon).reorder("week desc").count}]
                             elsif  params[:group]=="month"
                               Organization.where(:organization_type => "Publisher").map{|p| {name: p.organization_name, data: Story.where(:status => Story.statuses[:published]).where.not(:derivation_type => nil).where(:organization => p).group_by_month(:created_at).reorder("month desc").count}} +
                                 [{name: 'Storyweaver community', data: Story.where(:status => Story.statuses[:published]).where.not(:derivation_type => nil).where(:organization => nil).group_by_month(:created_at).reorder("month desc").count}]
                             elsif  params[:group]=="year"
                               Organization.where(:organization_type => "Publisher").map{|p| {name: p.organization_name, data: Story.where(:status => Story.statuses[:published]).where.not(:derivation_type => nil).where(:organization => p).group_by_year(:created_at).reorder("year desc").count}} +
                                 [{name: 'Storyweaver community', data: Story.where(:status => Story.statuses[:published]).where.not(:derivation_type => nil).where(:organization => nil).group_by_year(:created_at).reorder("year desc").count}]
                             else
                               Organization.where(:organization_type => "Publisher").map{|p| {name: p.organization_name, data: Story.where(:status => Story.statuses[:published]).where.not(:derivation_type => nil).where(:organization => p).group_by_day(:created_at).reorder("day desc").count}} +
                                 [{name: 'Storyweaver community', data: Story.where(:status => Story.statuses[:published]).where.not(:derivation_type => nil).where(:organization => nil).group_by_day(:created_at).reorder("day desc").count}]
                             end
      @derivative_stories_count = Story.where(:status => Story.statuses[:published]).where.not(:derivation_type => nil).count
      @derivative_stories_table = {}
      @derivative_stories.each do |k|
        if k[:data].present?
          k[:data].each do |key, value|
            if @derivative_stories_table[key].blank?
              @derivative_stories_table[key] = {k[:name]=>value}
            else
              @derivative_stories_table[key] = @derivative_stories_table[key].merge({k[:name]=>value})
            end
          end
        end
      end
    else
      @users = if  params[:group]=="week"
                 User.group_by_week(:created_at, week_start: :mon).count
               elsif  params[:group]=="month"
                 User.group_by_month(:created_at).count
               elsif  params[:group]=="year"
                 User.group_by_year(:created_at).count
               else
                 User.group_by_day(:created_at).count
               end
      @user_count = User.count
      @unconfirmed_user = User.where(confirmed_at: nil).count
    end
  end

  def most_read_stories
    @current_tab = "most_read_stories"
    @read_stories_current_tab = "most_read_stories"
    @languages = Language.all
    @stories_by_organization = Story.reorder("reads DESC").limit(10)
    language = Language.find_by_name(params[:language]) if params[:language]&& params[:language] != ''
    conditions = {:status => Story.statuses[:published]}
    conditions.merge!(:language => language) if language
    conditions.merge!(:reading_level => params[:level]) if params[:level] && params[:level] != ''
    limit = params[:limit] ? params[:limit] : 10
    @stories_by_filter = Story.where.not(:reads => 0).reorder("reads DESC").where(conditions).limit(limit)

  end

  def words_added_daily
    @current_tab = "words_added_daily"
    @words_added_daily = {}
    Language.pluck(:name).each do |language|
        stories = Story.search("*", where: {language: language, status: "published"}, order: {published_at: :desc}, load: false)
        stories = stories.group_by{|story| story.published_at.to_datetime.strftime("%d-%m-%Y")} if stories
        @words_added_daily[language]={}
        stories.each do |date, pages|
          contents = pages.map{|pages| pages.content}.compact.flatten
          @words_added_daily[language][date] = contents.map{|content| content.split(" ").uniq.count}.sum
        end
    end
    @words_added_daily
  end

  def languagewise_read_stories
    @current_tab = "most_read_stories"
    @read_stories_current_tab = "languagewise_read_stories"
    limit = params[:limit] ? params[:limit].to_i : 10
    @languagewise_read_count = Language.unscoped.joins("JOIN stories ON languages.id = stories.language_id").joins("JOIN story_reads ON stories.id = story_reads.story_id")

    @languagewise_read_count = @languagewise_read_count.where("story_reads.created_at >= ?", 1.month.ago) if params[:search_from] == "One Month"
    @languagewise_read_count = @languagewise_read_count.where("story_reads.created_at >= ?", 3.month.ago) if params[:search_from] == "Three Months"
    @languagewise_read_count = @languagewise_read_count.where("story_reads.created_at >= ?", 6.month.ago) if params[:search_from] == "Six Months"
    @languagewise_read_count = @languagewise_read_count.where("story_reads.created_at >= ?", 1.year.ago) if params[:search_from] == "One Year"
    @languagewise_read_count = @languagewise_read_count.all if params[:search_from] == "All Languages"
    @languagewise_read_count = @languagewise_read_count.where("story_reads.created_at::date >= ? and story_reads.created_at::date <= ?", params[:start_date], params[:end_date]) if params[:start_date].present? && params[:end_date].present?

    @languagewise_read_count = @languagewise_read_count.group('languages.id').select("languages.*, COUNT(story_reads.id) as read_count").reorder('read_count DESC').limit(limit)

  end

  def languages_added
    @current_tab = "languages_added"
    @languages_added = Language.unscoped.all.group_by{ |u| u.created_at.beginning_of_month }

  end

  def most_viewed_illustrations
    @current_tab = "most_viewed_illustrations"
    @organizations = Organization.where(:organization_type => "Publisher")
    organization = Organization.find_by_organization_name(params[:organization]) if params[:organization]
    conditions = {}
    conditions.merge!(:organization => organization ? organization : nil) if organization || params[:organization] == "community"
    limit = params[:limit] ? params[:limit] : 10
    @illustrations_by_organization = Illustration.where(conditions).count
    @most_viewed_illustrations = Illustration.where.not(:reads => 0).reorder("reads DESC").where(conditions).limit(limit)
  end

  def most_used_illustrations
    @current_tab = "most_used_illustrations"
    @organizations = Organization.where(:organization_type => "Publisher")
    organization = Organization.find_by_organization_name(params[:organization]) if params[:organization]
    conditions = {}
    conditions.merge!(:organization => organization ? organization : nil) if organization || params[:organization] == "community"
    limit = params[:limit] ? params[:limit] : 10

    @top_used_illustrations = Illustration.where(conditions).select("illustrations. *, count(stories.id) story_count")
                             .joins("LEFT JOIN illustration_crops on illustration_crops.illustration_id = illustrations.id
                      LEFT JOIN pages on pages.illustration_crop_id = illustration_crops.id
                      LEFT JOIN stories on stories.id = pages.story_id AND stories.status = 1").group("illustrations.id").order("story_count DESC").limit(limit)

  end

  def most_downloaded_stories
    @current_tab = "most_downloaded_stories"
    @languages = Language.all
    @low_res_pdf_downloads = Story.where(:status => Story.statuses[:published]).sum(:downloads)
    @high_res_pdf_downloads = Story.where(:status => Story.statuses[:published]).sum(:high_resolution_downloads)
    @epub_downloads = Story.where(:status => Story.statuses[:published]).sum(:epub_downloads)
    language = Language.find_by_name(params[:language]) if params[:language]&& params[:language] != ''
    conditions = {:status => Story.statuses[:published]}
    conditions.merge!(:language => language) if language
    conditions.merge!(:reading_level => params[:level]) if params[:level] && params[:level] != ''
    limit = params[:limit] ? params[:limit] : 10

    @language =  Language.all
    @languagewise_download_count ={}
    @language.each do |lang|
      download_count = Story.where(:status => Story.statuses[:published], language_id: lang.id).where.not(:organization => nil).sum('downloads + high_resolution_downloads + epub_downloads')
      @languagewise_download_count[lang.name] = download_count
    end

    @languagewise_download_count = Hash[@languagewise_download_count.sort_by{|k, v| v}.reverse]

    @levelwise_download_count = {}
    Story::READING_LEVELS.each do |k, v|
       download_count = Story.where(:status => Story.statuses[:published], reading_level: v).where.not(:organization => nil).sum('downloads + high_resolution_downloads + epub_downloads')
      @levelwise_download_count[k] = download_count
    end

    @levelwise_download_count = Hash[@levelwise_download_count.sort_by{|k, v| v}.reverse]

    @downloads_by_filter = Story.reorder("downloads+high_resolution_downloads+epub_downloads DESC").where(conditions).limit(limit)
  end

  def most_downloaded_illustrations
    @current_tab = "most_downloaded_illustrations"
    @low_res_pdf_downloads = Illustration.joins(:illustration_downloads).where("download_type = ?", "large").count
    @high_res_pdf_downloads = Illustration.joins(:illustration_downloads).where("download_type = ?", "original").count
    conditions = {}
    limit = params[:limit] ? params[:limit] : 10
    @downloads_by_filter = Illustration.select("illustrations. *, count(illustration_downloads.id) downloads_count").joins(:illustration_downloads).group("illustrations.id").reorder('downloads_count desc').where(conditions).uniq.limit(limit)
  end

  def organization_users
    @current_tab = "organization_downloads"
    @organization_current_tab = "organization_users"
    @organization_users = User.where.not(:organization_id => nil).reorder("created_at DESC")
  end

  def organization_downloads
    @current_tab = "organization_downloads"
    @organization_current_tab = "summery"
    get_organization_graph(params[:group])
    @stories_download_count = get_total_download_count
    @organization_users_count = Organization.all.count
    @children_impacted_count = Organization.sum(:children_impacted)
    respond_to do |format|
      format.html { render "organization_downloads"}
      format.js {render "story_dwonload_analytics"}
    end
  end
 
  def get_organization_graph(group)
     @story_downloads = if group =="week" 
                     [{name: 'Organisational download', data:  Story.joins(:story_downloads).where("story_downloads.organization_user =?",true)
                                                                   .group_by_week("story_downloads.created_at")
                                                                   .reorder("week desc").count, type: "Week"}]
                 elsif  group =="month"
                     [{name: 'Organisational download', data: Story.joins(:story_downloads).where("story_downloads.organization_user =?",true)
                                                                  .group_by_month("story_downloads.created_at")
                                                                  .reorder("month desc").count, type: "Month"}]
                 elsif  group =="year"
                     [{name: 'Organisational download', data:  Story.joins(:story_downloads).where("story_downloads.organization_user =?",true)
                                                                   .group_by_year("story_downloads.created_at")
                                                                   .reorder("year desc").count, type: "Year"}]
                 else
                     [{name: 'Organisational download', data:  Story.joins(:story_downloads).where("story_downloads.organization_user =?",true)
                                                                   .group_by_day("story_downloads.created_at")
                                                                   .reorder("day desc").count, type: "Day"}]
                 end
  end

  def get_total_download_count
    @organization_user = Organization.all
    @stories_count = 0
    @organization_user.each do|org|
      org.users.each do|user|
        @get_stories_download_count = user.story_downloads.where(:organization_user => true).reorder("created_at DESC")
        @get_stories_download_count.each do|story_download|
          @stories_count += story_download.stories.count
        end
      end
    end
    return @stories_count
  end

  def organization_user
    @organization = Organization.find(params[:id])
    org_user_ids = @organization.users.collect(&:id)
    @story_downloads = StoryDownload.where(:user_id => org_user_ids, :organization_user => true)
                                     .reorder("created_at DESC").page(params[:page]).per(12)
  end

  def stories_downloaded_list
    @story_download = StoryDownload.find(params[:story_download_id])
    @stories = @story_download.stories
  end

  def story_bulk_downloads
    @current_tab = "organization_downloads"
    @organization_current_tab = "bulk_downloads"
    @stories = StoryDownload.where(:organization_user => true).reorder("created_at DESC").page(params[:page]).per(12)
  end

  def story_downloads_date_sort
    @current_tab = "organization_downloads"
    @organization_current_tab = "bulk_downloads"
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @stories = StoryDownload.where(:organization_user => true, :created_at => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
                            .reorder("created_at DESC").page(params[:page]).per(12)
    @flag = true
      respond_to do |format|
        format.html { 
          render "story_bulk_downloads", :locals => {:stories => @stories, :flag => @flag,:start_date => @start_date, :end_date => @end_date}
        }
        format.js {
          render "story_downloads_date_sort"
        }
      end
  end

  def create_style
     @style = IllustrationStyle.new
     @style.name =  (params[:style][:name]).try(:strip)
     @style.translated_name = (params[:style][:name]).try(:strip)
     if @style.save
      translation = @style.translations.new
      translation.name = (params[:style][:name]).try(:strip)
      translation.translated_name = (params[:style][:translated_name]).try(:strip)
      translation.locale = "hi"
      translation.save!
     else
      flash[:errors] = @style.errors.messages
     end

     redirect_to styles_path
  end

  def flagged_stories
    @current_tab = "flagged_stories"
    @flagged_stories = Story.flagged.includes(:flaggings).reorder("flaggings.updated_at desc") #.page(params[:page]).per(12)
  end

  def pulled_down_stories
    @current_tab = "pulled_down_stories"
    @stories = Story.includes(:pulled_downs).where("pulled_downs.pulled_down_id IS NOT ?", nil).de_activated.reorder("pulled_downs.updated_at desc")
  end

  def pull_down_story
    @story = Story.find_by_id(params[:id])
    @pulled_down = PulledDown.new
    @pulled_down.pulled_down_id = params[:id]
    @pulled_down.pulled_down_type = "stories".classify.constantize.to_s
    @pulled_down.reason = params[:reasons]
    @pulled_down.save
    @story.send_pulled_down_notification(params[:reasons]) if @story.update_attributes(:status => "de_activated")
    redirect_to flagged_stories_path
  end

  def bulk_pull_down_stories
    story_ids = params["story_ids"].split(",").map{|id| id.to_i}
    @stories = Story.where(id: story_ids)
    @stories.each do |story|
      @pulled_down = PulledDown.new
      @pulled_down.pulled_down_id = story.id
      @pulled_down.pulled_down_type = "stories".classify.constantize.to_s
      @pulled_down.reason = params[:reasons]
      @pulled_down.save
      story.send_pulled_down_notification(params[:reasons]) if story.update_attributes(:status => "de_activated")
    end
    redirect_to flagged_stories_path
  end

  def bulk_pull_down_illustrations
    illustration_ids = params["illustration_ids"].split(",").map{|id| id.to_i}
    @illustrations = Illustration.where(id: illustration_ids)
    @illustrations.each do |illustration|
      @pulled_down = PulledDown.new
      @pulled_down.pulled_down_id = params[:id]
      @pulled_down.pulled_down_type = "illustration".classify.constantize.to_s
      @pulled_down.reason = params[:reasons]
      @pulled_down.save
      if illustration.update_attributes(:is_pulled_down => true)
        pulled_down_stories = illustration.used_in_published_stories.map {|story| story}
        pulled_down_stories.map {|story| story.update_attributes(:status => "de_activated")}
        illustration.send_pulled_down_notification(pulled_down_stories,params[:reasons])
      end
    end
    redirect_to flagged_illustrations_path
  end

  def clear_story_flag
    @story = Story.find_by_id(params[:id])
    @story.flaggings.destroy_all
    @story.flaggings_count = nil
    @story.save
    redirect_to flagged_stories_path
  end

  def activate_story
    @story = Story.find_by_id(params[:id])
    @story.flaggings.destroy_all if @story.flaggings.any?
    @story.pulled_downs.destroy_all if @story.pulled_downs.any?
    @story.flaggings_count = nil
    @story.status = 'published'
    @story.save
    redirect_to pulled_down_stories_path
  end

  def flagged_illustrations
    @current_tab = "flagged_illustrations"
    @flagged_illustrations = Illustration.flagged 
  end

  def pulled_down_illustrations
    @current_tab = "pulled_down_illustrations"
    @illustrations = Illustration.pulled_down
  end

  def pull_down_illustration
    @illustration = Illustration.find_by_id(params[:id])
    @pulled_down = PulledDown.new
    @pulled_down.pulled_down_id = params[:id]
    @pulled_down.pulled_down_type = "illustration".classify.constantize.to_s
    @pulled_down.reason = params[:reasons]
    @pulled_down.save
    if @illustration.update_attributes(:is_pulled_down => true)
      pulled_down_stories =  @illustration.used_in_published_stories.map {|story| story}
      pulled_down_stories.map {|story| story.update_attributes(:status => "de_activated")}
      @illustration.send_pulled_down_notification(pulled_down_stories,params[:reasons])
    end

    redirect_to flagged_illustrations_path
  end

  def clear_illustration_flag
    @illustration = Illustration.find_by_id(params[:id])
    @illustration.flaggings.destroy_all
    redirect_to flagged_illustrations_path
  end

  def activate_illustration
    @illustration = Illustration.find_by_id(params[:id])
    @illustration.flaggings.destroy_all if @illustration.flaggings.any?
    @illustration.pulled_downs.destroy_all if @illustration.pulled_downs.any?
    @illustration.update_attributes(:is_pulled_down => false)
    @illustration.used_in_de_activated_stories.map {|story| story.update_attributes(:status => "published") }
  
    redirect_to pulled_down_illustrations_path
  end

  def recently_published
    @current_tab = "recently_published"
    limit = 10000
    @stories =  Story.search("*", where: {status: "published"}, order: {published_at: "desc"}, limit: limit, load: false) 
  end

  def autocomplete
    render json: User.search(params[:query], {
                                             fields: ["email^5", "first_name", "last_name"],
                                             limit: 10,
                                             load: false,
                                             misspellings: {below: 5}
                                           }).map{|u| "#{u.email}, #{u.first_name}, #{u.last_name}"}
  end

  def banned_users
    @current_tab = "banned_users"
    @users = User.where(is_banned: true)
  end
    
  def ban_user
    @user = User.find_by(email: params[:user][:email])
    if @user.present? && !@user.is_banned?
      @user.update_attributes(is_banned: true) 
      flash[:notice] = "User banned successfully"
        redirect_to banned_users_path
    else
      flash[:error] = "Either user is already banned or user not found in our database"
      redirect_to banned_users_path
    end
  end
 
  def unban_user
    @user = User.find_by(id: params[:user_id])
    @user.update_attributes(is_banned: false) 
    redirect_to banned_users_path
  end

  private

  def import_partner_check
    @current_tab = OPDS_MANAGEMENT_TAB
    @sub_tab = IMPORT_PARTNER_SUB_TAB

    @import_partner = ImportPartner.find_by_id(params[:id])
    
    if @import_partner == nil
      flash[:error] = "Could not find import partner with ID : #{params[:id]}"
      redirect_to opds_management_path
      return
    end    
  end

  def is_there_flagging_comment(user_input)
    user_input.each {|i| return true if ReviewerComment::FLAGGING_COMMENTS.include?(i)}
    return false
  end

  def filter_flagging_comments(comments)
    return comments.reject {|k| !ReviewerComment::FLAGGING_COMMENTS.include?(k)}
  end

  def is_there_review_comment(user_input)
    user_input.each {|i| return true if ReviewerComment::REVIEW_COMMENTS.include?(i)}
    return false
  end

  def filter_review_comments(comments)
    return comments.reject {|k| !ReviewerComment::REVIEW_COMMENTS.include?(k)}
  end

  def handle_extra_input(comments)
    other_comments_str = "other_comments"
    others_str = "Others"
    primary_comments = comments.keys
    if primary_comments.include?(other_comments_str) && !primary_comments.include?(others_str)
      comments.delete(other_comments_str)
    end
    if primary_comments.include?(other_comments_str) && primary_comments.include?(others_str)
      comments[others_str] = [comments[other_comments_str]]
      comments.delete(other_comments_str)
    end
  end

  def send_mail_if_level_mismatch(comments, story)
    comments.values.flatten.each do |sub_comment|
      if sub_comment.include?(ReviewerComment::READING_LEVEL_MISMATCH_TXT)
        story.authors.each do |author|
          UserMailer.delay(:queue => "mailer").reading_level_mismatch_mail(story, author.name.titleize, author.email)
        end
      end 
    end
  end

  def upload_running?
    Delayed::Job.select{|job| job.queue == StoryUpload::Uploader::STORY_UPLOAD_QUEUE}.length != 0
  end

  def authorize_action
    authorize self, :default
  end

  def analytics_access
    authorize self, :analytics
  end

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "first_name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def import_partner_params
    params.require(:import_partner).permit(:attribution_name, :url, :prefix, :organization_name, :organization_id)
  end

  def token_params
    params.require(:token).permit(:story_download_limit, :illustration_download_limit, :valid_for, :organization_id, :organization_name)
  end
end
