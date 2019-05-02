include ApplicationHelper
include BulkDownload # including lib/bulk_download.rb module.
  
require 'utils/utils'
require 'fileutils'
class StoriesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :other_reading_levels, :versions, :cover, :start, :translate, :translate_suggestions, :show_in_iframe, :update_story_read, :reset_story_download_count, :autocomplete]
  autocomplete :tag, :name, :class_name => 'ActsAsTaggableOn::Tag'

  def start
    @menu = "start"
    @contest = Contest.find_by_id(params[:contest_id]) unless (params[:contest_id].nil?) #RRR 2017
  end

  def translate
    @menu = "translate"
    @contest = Contest.find_by_id(params[:contest_id]) unless (params[:contest_id].nil?) #RRR 2017
  end

  def translate_suggestions
    @contest_id = params[:contest_id]
    @search_params = params[:search]
  end

  def new
    @story = Story.find_by_id(params[:id])
    @contest = Contest.find_by_id(params[:contest_id]) unless (params[:contest_id].nil?) #RRR 2017
    respond_to do |format|
      format.html {redirect_to "/start#{@contest.present? ? '?contest_id='+params[:contest_id].to_s : '' }"}
      format.js 
    end
  end

  def editable
    @story = Story.find_by_id params[:id]
    authorize @story, :editable?
    if @story.nil?
      flash[:error]="Unable to find story"
      redirect_to root_path
      return
    end

    @story.update_attributes(:status => :edit_in_progress) if @story.published?
    redirect_to story_editor_path(@story)
  end

  def create_story
    params[:story] = default_params
    @contest = Contest.find_by_id(params[:contest_id]) unless params[:contest_id].nil?
    params[:story][:contest_id] = @contest.present? ? @contest.id : nil
    @story = Story.new(story_params)
    if current_user.organization?
      @story.organization = current_user.organization
      @story.status = Story.statuses[:uploaded]
    else
      @story.authors = [current_user]
    end
    @story.title = story_params[:title].present? ? story_params[:title] : Story.generate_title_for(@story)
    @story.user_title = true if story_params[:title].present?
    if @contest.present?
      @story.tag_list = "," + @contest.tag_name if @contest.tag_name.present?
    end

    if @story.save && @story.build_book(nil,true)
      PiwikEvent.create(category: 'Story',action: 'Create',name: 'Online')
      PiwikEvent.create(category: 'Story - Language',action: "Create - #{@story.language.name}")
      PiwikEvent.create(category: 'Story - Level',action: "Create - #{@story.reading_level}")
      respond_to do |format|
        if @contest
         format.html { redirect_to story_editor_path(@story, :contest_id => @contest.id) }
       else
         format.html { redirect_to story_editor_path(@story) }
       end
        format.js {}
      end
    else
      flash[:error] = @story.errors.full_messages.join(", ")
      redirect_to :back
    end
  end

  def default_params
    {:language_id => Language.find_by_name("English").id, :orientation => "landscape", :reading_level => Story.reading_levels['1']}
  end

  def new_story_from_illustration
    @illustration = Illustration.find_by_id(params[:id])
    @contest = Contest.find_by_id(params[:contest_id]) unless (params[:contest_id].nil?)
    @story = Story.new
  end

  def create_story_from_illustration
    params[:story] = default_params
    params[:story][:illustration_id] = params[:id]
    @contest = Contest.find_by_id(params[:story][:contest_id]) unless params[:story][:contest_id].nil?
    @illustration = Illustration.find_by_id(params[:story][:illustration_id])
    story_creation_from_illustration
   
=begin
        =begin
      if @contest.present? 
            contest_has_illustration = @contest.illustrations.find_by_id(@illustration).present? 
            if contest_has_illustration
              story_creation_from_illustration
            else 
              flash[:notice] = "Selected illustration is not in this contest"
              render :contest_path
            end
          else
          =end
=end
  end

  def story_creation_from_illustration
    @story = Story.new(story_params)
      if current_user.organization? 
        @story.organization = current_user.organization
        @story.status = Story.statuses[:uploaded]
      else
        @story.authors = [current_user]
      end

      @story.title = story_params[:title].present? ? story_params[:title] : Story.generate_title_for(@story)
      @story.user_title = true if story_params[:title].present?
      
      if @story.save && @story.build_book(nil,true,@illustration)
        @illustration.favorites << @story unless @illustration.favorites.find_by_id(@story)
        @illustration.reindex
        PiwikEvent.create(category: 'Story',action: 'Create',name: 'Online')
        PiwikEvent.create(category: 'Story - Language',action: "Create - #{@story.language.name}")
        PiwikEvent.create(category: 'Story - Level',action: "Create - #{@story.reading_level}")
        respond_to do |format|
          format.html { redirect_to story_editor_path(@story) }
          format.js {}
        end
      else
        @errors=@story.errors.full_messages.join(", ")
        redirect_to :back
      end
  end

  def show
    if params[:contest_id].present?
      @contest = Contest.find(params[:contest_id]) 
    end
    @story = Story.eager_load([:language,:authors,:organization,:categories,{:pages=>[:page_template,{:illustration_crop=>{:illustration=>:illustrators}}]}]).order("pages.position ASC").order("story_category_id").find_by_id(params[:id])
    @similar_stories = @story.similar(fields: [:language , :reading_level, :categories], where: {status: "published", language: @story.language.name, reading_level: @story.reading_level}, limit: 12, order: {_score: :desc}, operator: "and", load: false).results if @story rescue []
    return render_404 if @story.nil? || @story.publish_pending?
    return render_404 if (@story.nil? || @story.de_activated?) && !user_signed_in?
    return authenticate_user! if (@story.draft? || @story.uploaded?) && !user_signed_in?
    return respond_to_show if (@story.draft? || @story.uploaded? || @story.de_activated? ) && authorize(@story, :show?)
    return respond_to_show
  end

  def show_in_iframe
    @story = Story.eager_load([:language,:authors,:organization,:categories,{:pages=>[:page_template,{:illustration_crop=>{:illustration=>:illustrators}}]}]).order("pages.position ASC").order("story_category_id").find_by_id(params[:id])
    @disable_review_link = params[:disable_review_link] if params[:disable_review_link].present?
  end

  def publish
    @story = Story.find_by_id(params[:id])
    if params[:audio_publish]
      if (@story.audio_status != "audio_draft" || !can_publish?)
        redirect_to published_audio_stories_path, :flash => { :error => "You don't have the rights to publish this story!"} and return
      else
        @story.audio_status = "audio_published"
        @story.save!
        redirect_to published_audio_stories_path, :flash => { :notice => "Wohooo! Your audio story is published." } and return
      end
    end

    if !((@story.uploaded? || @story.draft?) && can_publish?)
      redirect_to dashboard_path, :flash => { :error => "You don't have the rights to publish this story!"} and return
    elsif !@story.process_publish
      redirect_to dashboard_path, :flash => { :error => @story.errors.full_messages.join(", ") } and return
    end

    redirect_to dashboard_path, :flash => { :notice => "Wohooo! Your story will appear on the Homepage in a short while." }
  end

  def story_review
    @flag = params[:flag] 
    @story = Story.find(params[:id])
    @current_user = current_user
    if @flag == "true"
      @flag = true
     if !@story.flagged?
       if current_user && current_user.is_language_reviewer(@story.language.name)
         if @story.reviewer_comment.present?
           flash[:error] = "Story has been already reviewed."
           redirect_to root_path
         else
           @reviewer_comment = ReviewerComment.new
           @flag = MakeFlaggable::Flagging.new
         end
       else
         flash[:error] = "You are not authorised to do this."
         redirect_to root_path
       end
     else
       flash[:error] = "This story has been flagged"
       redirect_to root_path 
     end
   else
    @reviewer_comment = ReviewerComment.new
    @flag = false
    @english_story = @story.get_english_version(@current_user)
   end
  end

  def story_review_new
    @flag = params[:flag] 
    @story = Story.find(params[:id])
    @current_user = current_user
    if @flag == "true"
      @flag = true
      if !@story.flagged?
        if current_user && (current_user.is_language_reviewer(@story.language.name) || current_user.content_manager?)
          if @story.reviewer_comment.present?
            flash[:error] = "Story has been already reviewed."
            redirect_to root_path
          else
            @languages = Language.list_for_story_rating
            @reading_levels = Story::READING_LEVELS.keys
            @reviewer_comment = ReviewerComment.new
            @flag = MakeFlaggable::Flagging.new
          end
        else
          flash[:error] = "You are not authorised to do this."
          redirect_to root_path
        end
      else
        flash[:error] = "This story has been flagged"
        redirect_to root_path 
      end
    else
      @languages = Language.list_for_story_rating
      @reading_levels = Story::READING_LEVELS.keys
      @reviewer_comment = ReviewerComment.new
      @flag = false
      @english_story = @story.get_english_version(@current_user)
    end
  end

  def reviewer_comments
    handle_extra_input(params[:reviewer_comment][:comments])
    params[:reviewer_comment][:comments].each {|k, v| v.delete("")}
    primary_comments = params[:reviewer_comment][:comments].keys
    if is_there_flagging_comment(primary_comments)
      @story = Story.find_by_id(params[:id])
      Rails.logger.info "### Flagging Story with ID #{@story.id} ###"
      @path = params[:type] if params[:type].present?
      user = current_user
      comments = filter_flagging_comments(params[:reviewer_comment][:comments])
      reason = JSON.generate(comments)
      user.flag(@story, reason)
      content_managers = User.content_manager.collect(&:email).join(",")
      data_for_email = ReviewerComment.construct_comment_text(reason)
      UserMailer.delay(:queue => "mailer").flagged_story(content_managers, @story, user, data_for_email, @path)
      send_mail_if_level_mismatch(comments, @story)
      flash[:error] = "The story has been flagged. Thank you for drawing our attention to this story."
    end
      @reviewer_comment = ReviewerComment.new()
      @story = Story.find_by_id(params[:id])
      @reviewer_comment.story_id = params[:id] 
      @reviewer_comment.user_id = current_user.id
      @reviewer_comment.language_id = @story.language.id
      if !@story.reviewer_comment.present?
        Rails.logger.info "### Review comment will be created for Story with ID #{@story.id} ###"
        @reviewer_comment.story_rating = params[:reviewer_comment][:story_rating].to_i if  params[:reviewer_comment][:story_rating] != nil
        @reviewer_comment.language_rating = params[:reviewer_comment][:language_rating].to_i if  params[:reviewer_comment][:language_rating] != nil
        @reviewer_comment.rating = params[:reviewer_comment][:rating] if params[:reviewer_comment][:rating] != "0"
        @reviewer_comment.comments = JSON.generate(params[:reviewer_comment][:comments])
        if @reviewer_comment.save
            @language = Language.find_by_id(@story.language.id)
            conditions = {:status => Story.statuses[:published], :language =>@language,:organization_id => nil, :flaggings_count => nil}
            @stories = Story.joins(:authors).where("authors_stories.user_id !=?",current_user)
                            .joins("LEFT OUTER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                            .where("reviewer_comments.story_id IS ?", nil)
                            .where(conditions).reorder("published_at ASC")
            Story.find_by_id(params[:id]).reindex
            flash[:notice] = "Thank you for rating this story" if !@story.flagged?
        else
          flash[:error] = "Unable to save reviewer comment"
        end
      else
        respond_to do |format|
          flash[:error] = @story.flagged? ? "Story is no longer available for review." : "Story has been already reviewed."
            format.js {render js: "window.location = '#{ reviewer_un_reviewed_stories_path }';"}
          end
      end
    redirect_to reviewer_un_reviewed_stories_path
  end

  def destroy
    @story = Story.find_by_id(params[:id])
    render_404 if @story.nil?
    if @story.uploaded?  && current_user.content_manager?
      Story.searchkick_index.remove(@story)
      @story.destroy
      respond_to do |format|
        flash[:notice] = "Story deleted successfully"
        format.html { redirect_to dashboard_path }
        format.js {}
      end
    else
      respond_to do |format|
        format.html {
          flash[:error]="Unable to delete story"
          redirect_to react_stories_show_path(@story.to_param)
        }
        format.js { render :destroy_error }
      end
    end
  end

  def versions
    @story = Story.find_by_id(version_params[:id])
    language = version_params[:language]
    reading_level = version_params[:reading_level]
    @versions = @story.versions(language, reading_level)
    if @versions.length == 1
      redirect_to react_stories_show_path(@versions.first.to_param)
    end
  end

  def autocomplete
    stories = Story.search(params[:query], {
                                             fields: ["id^5", "title", "english_title"],
                                             limit: 10,
                                             load: false,
                                             misspellings: {below: 3}
                                           })
     results = []
     stories.each do |story|
       results << "#{story.id}, #{story.title}, #{story.english_title}"
     end
    render json: results
  end

  def reviewer_rating_comment
    story = Story.find(params[:story_id]) if !params[:story_id].empty?
    @ratings = Rating.new
    @ratings.rateable = story
    @ratings.user_id = current_user.id
    @ratings.user_comment = params[:comment]
    @ratings.user_rating = params[:rating]
    
    if @ratings.save
      content_managers=User.content_manager.collect(&:email).join(",")
      UserMailer.delay(:queue=>"mailer").reviewer_rating_comment(content_managers,story,current_user)
      respond_to do |format|
        format.html
        format.js
      end
    else
      flash[:errors] = @ratings.errors.messages
    end
  end

  def update_story_read
    story_read = StoryRead.find(params[:story_read_id])
    if story_read.is_completed == false
      story_read.update_attributes(:is_completed => true,:finished_at => DateTime.now)
      story_read.save
    end
    respond_to do |format|
     format.json { head :ok }
    end
  end

=begin
  def update_book_read
    book_read = BookRead.find(params[:book_read_id])
    if book_read.is_completed == false
      book_read.update_attributes(:is_completed => true)
      book_read.save
    end
    respond_to do |format|
     format.json { head :ok }
    end
  end
=end

  def edit_story_editor
    @story = Story.find_by_id(params[:id])
  end

  def close_assign_dailog
    @story = Story.find_by_id(params[:id])
  end

  def assign_change_editor
    @story = Story.find_by_id(params[:id]) if params[:id].present?
      @user = User.find_by_email(params[:story][:editor_id].split(',').first)
      if @user.present? && @story.editor != @user  
        if @story.update_attributes(:editor_id => @user.id)
          redirect_to react_stories_show_path(@story.to_param)
        end
      else
        flash[:errors] = "Email can't be blank" if params[:story][:editor_id].blank?
        flash[:errors] = 'User does not exist' if !@user.present? && !params[:story][:editor_id].blank?
        flash[:errors] = 'You have already assigned this editor' if @story.editor && @story.editor == @user
        redirect_to react_stories_show_path(@story.to_param)
      end
  end

  def new_flag_story
    @story = Story.find_by_id(params[:id])
    @flag = MakeFlaggable::Flagging.new
  end

  def flag_story
    @story = Story.find_by_id(params[:id])
    user = current_user
    @errors = []
    @path = params[:type] if params[:type].present?
    if user.flagged?(@story) 
      @errors << "you have alreay flagged this story"
      render :new_flag_story
    else
      if !params[:reasons].blank?
          user.flag(@story, params[:reasons])
          content_managers=User.content_manager.collect(&:email).join(",")
          reason = params[:reasons]
          UserMailer.delay(:queue=>"mailer").flagged_story(content_managers,@story,user,reason,@path)
          flash[:error] = "Story has been flagged"
      else
        @errors << "Reason can't be blank"
        render :new_flag_story
      end
    end
  end

  def create_post
    @errors=[]
    @story = Story.find_by_id(discussion_post_params[:id])
    if discussion_post_params[:raw].blank?
      @errors << "comment can't be blank"
    else
      begin
        Discussion.create_user(current_user) rescue true
        Discussion.create_post(discussion_post_params[:topic_id], discussion_post_params[:raw], current_user)
        @story.reload
      rescue Exception => e
        logger.error("Unable to create post on discourse for story id: #{@story.topic_id}, topic id: #{discussion_post_params[:topic_id]}, raw: #{discussion_post_params[:topic_id]} . Error #{e}")
        response = JSON.parse e.to_json
        @errors << (response['wrapped_exception']['errors'].blank? ? 'Unable to post comment due to technical issues, please try again, after some time.' : response['wrapped_exception']['errors'].join(', '))
        respond_to do |format|
          format.js {render :create_post_errors}
        end
      end
    end
  end

  def recommend_story_on_home
    story = Story.find_by_id(params[:story_id].to_i)
    if story && !story.recommendation
      story.recommendation_update(params[:recommend])
      story.reindex
      flash[:notice] = "Story recommended successfully"
    end

    @story = Story.find_by_id(params[:story_id].to_i)
    respond_to do |format|
      format.js
      format.json do
        render :json => :ok
      end
      format.html do
        redirect_to users_recommended_path
      end
    end 
  end

def download_story
    story = Story.find(params[:id])
    current_user.update_attribute(:story_download_count, (current_user.story_download_count + 1))
    if params[:format] == "epub"
      story.update_downloads_count("epub", current_user, request.remote_ip, falg=false)
    elsif params[:format] == "pdf"
      story.update_downloads_count(params[:high_resolution] ? "high" : "low", current_user, request.remote_ip,falg=false)
    end
    story_revision = story.revision.nil? ? '' : ('_'+(story.revision).to_s)
    if Rails.env.production?
      head(:not_found) and return if story.nil?
      directory = fog_directory
      if params[:format] == "epub"
        file = directory.files.get("stories/#{story.id}/epub/#{story.to_param}#{story_revision}.epub").public_url
        Rails.logger.info file
        filename = "#{story.to_param}.epub"
      elsif params[:format] == "pdf"
        file = directory.files.get("stories/#{story.id}/pdfs/#{params[:high_resolution] ? "high" : "low"}/#{story.to_param}#{story_revision}.pdf").public_url
        Rails.logger.info file
        filename = "#{story.to_param}.pdf"
      end
      data = open(file)
      send_data data.read, :filename=>filename, :dispostion=>'inline', :stream => true
    else
      head(:not_found) and return if story.nil?
      if params[:format] == "epub"
        send_file "#{Rails.root}/public/#{Settings.fog.directory}/stories/#{story.id}/epub/#{story.to_param}#{story_revision}.epub", :filename=>"#{story.to_param}.epub", :dispostion=>'inline'
      elsif params[:format] == "pdf"
        send_file "#{Rails.root}/public/#{Settings.fog.directory}/stories/#{story.id}/pdfs/#{params[:high_resolution] ? "high" : "low"}/#{story.to_param}#{story_revision}.pdf", :filename=>"#{story.to_param}.pdf", :dispostion=>'inline'
      end
    end
 end

  # /v0/stories/reset_story_download_count
 def reset_story_download_count
  current_user = User.find_by_email(params[:email])
  current_user.story_download_count = 0
  current_user.save!
  render json: {"ok"=>true}
 end

 def show_selected_stories
   @selected_stories = params[:stories_to_download] if params[:stories_to_download].present?
   @stories= []
   params[:stories_to_download].each do|story|
    @stories << Story.find(story)
   end
   @format = params[:type]
   @high_resolution = params[:resolution]
 end

  def bulk_download
    # lib/bulk_download.rb module
    bk_download params, current_user,request 
  end

  
  def make_story_static_files(story)
    directory = fog_directory
    story_revision = story.revision.nil? ? '_1' : ('_'+(story.revision + 1).to_s)
    save_story_pdf(story, story_revision, directory)
    save_story_epub(story, story_revision, directory)
    low_res_pdf = directory.files.get("stories/#{story.id}/pdfs/low/#{story.to_param}#{story_revision}.pdf")
    high_res_pdf = directory.files.get("stories/#{story.id}/pdfs/high/#{story.to_param}#{story_revision}.pdf")
    epub = directory.files.get("stories/#{story.id}/epub/#{story.to_param}#{story_revision}.epub")
    if epub && low_res_pdf && high_res_pdf
      story.update_revision
    else
      Rails.logger.info "Missing attachment for story: #{story.to_param}"
    end
    delete_older_files_from_cloud(story, story_revision, directory)
  end

  def regenerate_epub(story)
    directory = fog_directory
    revision = story.revision.nil? ? '' : ('_'+(story.revision).to_s)
    save_story_epub(story, revision, directory)
  end

  def regenerate_pdf(story)
    directory = fog_directory
    revision = story.revision.nil? ? '' : ('_'+(story.revision).to_s)
    save_story_pdf(story, revision, directory)
  end
 
  # Send level band path.
  def level_band
    story = Story.find(params[:story_id])
    reading_level = params[:reading_level] || story.reading_level
    lb_name = story.language.level_band ?  story.language.level_band : "English"
    render json: {"url" => ActionController::Base.helpers.asset_path("level_bands/Level_#{reading_level}_#{lb_name}.png")}
  end

  private

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

  def story_params
    params
      .require(:story)
      .permit(:title, :synopsis, :english_title, :language_id, :status, :reading_level, :organization_id, :story_id, :attribution_text , :orientation , :copy_right_year, :chaild_created, :dedication, :contest_id, category_ids: [])
  end

  def version_params
    params
    .permit(:id, :language, :reading_level)
  end

  def discussion_post_params
    params
      .require(:discussion)
      .permit(:id, :topic_id, :raw)
  end
  def can_publish?
    current_user.content_manager? 
  end

  def respond_to_show
    respond_to do |format|
      format.html do
        render
      end
      format.json do
        render json: {
          story: {
            title: @story.title,
            language: @story.language.name,
            reading_level: @story.reading_level,
            synopsis: @story.synopsis,
            organization: @story.organization.organization_name,
            created_at: @story.created_at,
            updated_at: @story.updated_at,
            derivation_type: @story.derivation_type,
            attribution_text: @story.attribution_text,
            recommended: @story.recommended,
            reads: @story.reads,
            likes: @story.likes
          },
          pages: @story.pages.map do |page|
            {
              rel: page.class.to_s.underscore.dasherize,
              uri: story_page_path(@story,page)
            }
          end,
          links: [
            {
              rel: 'root',
              uri: "/stories/#{@story.root.to_param}"
            },
            {
              rel: 'self',
              uri: "/stories/#{@story.to_param}"
            },
            {
              rel: 'versions',
              uri: "/stories/#{@story.to_param}/versions"
            },
            {
              rel: 'same-category',
              uri: url_for(controller: :search,action: :search, :only_path=> true, :search => {:categories => @story.categories.map(&:name)})
            },
            {
              rel: 'same-language',
              uri: url_for(controller: :search,action: :search, :only_path=> true, :search => {:languages => [@story.language.name]})
            },
            {
              rel: 'same-reading-level',
              uri: url_for(controller: :search,action: :search, :only_path=> true, :search => {:reading_levels => [@story.reading_level]})
            }
          ]
        }
      end
    end

  end

  def save_story_pdf(story, story_revision, directory)
    @story = story
    dir = Dir.mktmpdir

    @additional_illustration_license_types = if @story.license_type == "Public Domain"
                                               @story.illustration_license_types.reject{|license| license == 'Public Domain'}
                                             else
                                               @story.illustration_license_types.reject{|license| license == 'CC BY 4.0' || license == 'CC BY 3.0'}
                                             end

    ["high", "low"].each do |resolution|
      wicked = WickedPdf.new
      # Make a PDF
      pdf_file = wicked.pdf_from_string(
        ActionController::Base.new().render_to_string(
          :template   => 'pages/show.pdf.erb',
          :locals     => {
            :@story => story,
            :@additional_illustration_license_types => @additional_illustration_license_types,
            :debug => false,
            :resolution => resolution,
          }
        ),
        print_media_type: true,
        :pdf => @story.to_param,
        :page_size => 'A4',
        :orientation => @story.orientation.capitalize,
        :wkhtmltopdf => '/usr/local/bin/wkhtmltopdf',
        extra: resolution == "high" ? '--no-pdf-compression --image-quality 100 --image-dpi 3000' : '--image-quality 60' ,
        margin:     {:top               => 3,
                     :bottom             => 3,
                     :left               => 10,
                     :right              => 3}
      )
      File.open("#{dir}/#{story.to_param}#{story_revision}.pdf", 'wb') do |file|
        file << pdf_file
      end

      `./lib/scripts/add_stats_tracking_to_story.sh #{dir}/#{story.to_param}#{story_revision}.pdf #{story.hash_id} #{host_url}`
      
      file = directory.files.create(
        :key    => "stories/#{story.id}/pdfs/#{resolution}/#{story.to_param}#{story_revision}.pdf",
        :body => File.open("#{dir}/#{story.to_param}#{story_revision}.pdf"),
        :public => true
      )
      file.body = File.open("#{dir}/#{story.to_param}#{story_revision}.pdf")
      file.save
      File.delete("#{dir}/#{story.to_param}#{story_revision}.pdf") if File.exist?("#{dir}/#{story.to_param}#{story_revision}.pdf")
    end
    FileUtils.rm_rf("#{dir}") if File.exist?("#{dir}")
  end

  def save_story_epub(story, story_revision, directory)
    @story = story
    dir = Dir.mktmpdir
    pages = []
    images = []
    files=[]

    @additional_illustration_license_types =
      @story.illustration_license_types.reject{|license| license == 'CC BY 4.0' || license == 'CC BY 3.0'}


    @story.pages.each do |page|
      page_file = "#{dir}/#{page.position}"
      pages << page_file+".xhtml"
      unless page.illustration_crop.nil?
        image_file = "#{dir}/image_#{page.position}"
        images << image_file+".jpg"
        files << image_file+".jpg"
        FileUtils.cp page.illustration_crop.load_image(:size7), "#{image_file}.jpg"
      end
      templates_dir = "#{Rails.root}/app/views"
      av = ActionView::Base.new(templates_dir)
      av.assign({
                  :page => page
                })
      f = File.new(page_file+".xhtml", 'w')
      page = f.puts(av.render(:template => "pages/show.epub.erb", locals: {:page => page, :@story => @story, :@additional_illustration_license_types => @additional_illustration_license_types, :form_authenticity_token => nil,  :@offline_processing => true}))
      f.close
    end

    #copy publisher logo
    copy_organization_logo(@story, dir, files)

    #copy level bands
    copy_level_bands(@story, dir, files)

    # copy other static images
    copy_other_static_images(dir, files)

    #Embedding necessary fonts
    fonts = []
    embed_fonts(@story,dir,fonts) 

    name = @story.title
    author = who_did_it(@story)
    organization = (@story.organization.nil? ? 'StoryWeaver Community' : @story.organization.organization_name)
    date = @story.copy_right_year
    id = @story.id
    url = "/stories/#{@story.to_param}"
    language = @story.language.locale

    # Generating epub3 files form gepub gem
    builder = GEPUB::Builder.new {
      language language
      unique_identifier url, "Story-#{id}", 'URL'
      title name
      id "story_#{id}"
      creator author
      date Time.new(date ? date : 1980)

      resources(:workdir => dir) {

        cover_image 'image_1.jpg'

        fonts.each do |fon|
          file fon
        end

        files.each do |f|
          unless f.split('/')[-1].match('image_1.jpg')
            file f.split('/')[-1]
          end
        end

        ordered {
          pages.each do |pag|
            file pag.split('/')[-1]
            heading "Page #{pag.split('/')[-1].split('.')[0]}"
          end           
        }
      }
    } 

    builder.generate_epub("#{dir}/#{@story.to_param}#{story_revision}.epub")
    file = directory.files.create(
      :key    => "stories/#{@story.id}/epub/#{@story.to_param}#{story_revision}.epub",
      :body => File.open("#{dir}/#{@story.to_param}#{story_revision}.epub"),
      :public => true
    )
    file.save
    FileUtils.rm_rf("#{dir}") if File.exist?("#{dir}")
  end

  def copy_organization_logo(story, dir, files)
    logo_type = story.organization.present? ? story.organization.logo_content_type : ""
    extension = ".jpg"
    if(logo_type == "image/png")
      extension = ".png"
    elsif(logo_type == "image/gif")
      extension = ".gif"
    end
    FileUtils.cp Utils.download_to_file(organization_logo_pdf(story)), "#{dir}/publisher_logo#{extension}"
    files << "#{dir}/publisher_logo#{extension}"
  end

  def copy_level_bands(story, dir, files)
      FileUtils.cp open(level_band_image_pdf(story)), "#{dir}/level_band.png"
      files << "#{dir}/level_band.png"
  end

  def copy_other_static_images(dir, files)
    ['pb-storyweaver-logo-01.png', 'ccby.png', 'cc0.png', 'publicdomain.svg'].each do |image|
      logo_path = Rails.root.join('app', 'assets', 'images', image)
      FileUtils.cp open(logo_path), "#{dir}/#{image}"
      files << "#{dir}/#{image}"
    end
  end

  def embed_fonts(story, dir, fonts)

    storyFont = @story.language.language_font.font.gsub(/\s+/, "")
    Dir.mkdir("#{dir}/fonts")

    # Adding NotoSans by default
    Dir.mkdir("#{dir}/fonts/NotoSans")
    Dir.mkdir("#{dir}/fonts/NotoSans/Regular")
    Dir.mkdir("#{dir}/fonts/NotoSans/Bold")
    Dir.mkdir("#{dir}/fonts/NotoSans/Italic")
    Dir.mkdir("#{dir}/fonts/NotoSans/BoldItalic")

    ['Regular', 'Bold', 'Italic', 'BoldItalic'].each do |style|
      style_path = "#{Rails.root}/app/assets/fonts/NotoSans/#{style}/NotoSans-#{style}_gdi.woff"
      font_file = "#{dir}/fonts/NotoSans/#{style}/NotoSans-#{style}_gdi"
      fonts << "#{font_file.split('/').last(4).join('/')}.woff"
      FileUtils.cp open(style_path), "#{font_file}.woff"
    end
    
    if (['NotoNastaliqUrdu', "NotoSansMongolian", "NotoSansOlChiki"].include? storyFont)
      Dir.mkdir("#{dir}/fonts/#{storyFont}")
      regular_path = "#{Rails.root}/app/assets/fonts/#{storyFont}/#{storyFont}-Regular.woff"
      font_file_regular = "#{dir}/fonts/#{storyFont}/#{storyFont}-Regular"
      fonts << "#{font_file_regular.split('/').last(3).join('/')}.woff"
      FileUtils.cp open(regular_path), "#{font_file_regular}.woff"
    elsif storyFont != "NotoSans"
      Dir.mkdir("#{dir}/fonts/#{storyFont}")
      Dir.mkdir("#{dir}/fonts/#{storyFont}/Regular")
      Dir.mkdir("#{dir}/fonts/#{storyFont}/Bold")
      regular_path = "#{Rails.root}/app/assets/fonts/#{storyFont}/Regular/#{storyFont}-Regular.woff"
      bold_path = "#{Rails.root}/app/assets/fonts/#{storyFont}/Bold/#{storyFont}-Bold.woff"
      font_file_regular = "#{dir}/fonts/#{storyFont}/Regular/#{storyFont}-Regular"
      font_file_bold = "#{dir}/fonts/#{storyFont}/Bold/#{storyFont}-Bold"
      fonts << "#{font_file_regular.split('/').last(4).join('/')}.woff"
      fonts << "#{font_file_bold.split('/').last(4).join('/')}.woff"
      FileUtils.cp open(regular_path), "#{font_file_regular}.woff"
      FileUtils.cp open(bold_path), "#{font_file_bold}.woff"
    end
  end 
  


  #Removing old pdf's and epu files from google cloud
  def delete_older_files_from_cloud(story, story_revision, directory)
    if Rails.env == 'production'
      directory.files.all(:prefix=> "stories/#{story.id}/pdf").each do |file|
        file.destroy if (File.basename(file.key, File.extname(file.key)) != story.to_param + story_revision)
      end
      directory.files.all(:prefix=> "stories/#{story.id}/epub").each do |file|
        file.destroy if (File.basename(file.key, File.extname(file.key)) != story.to_param + story_revision)
      end
    end
  end 

end
