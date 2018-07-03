class Api::V1::StoriesController < Api::V1::ApplicationController
  
  before_action :authenticate_user!, only: [:flag_story, :add_to_editor_picks, :remove_from_editor_picks, :story_like, :story_unlike]
  
  respond_to :json
  def show
    @story = Story.eager_load([:language,:authors,:organization,:categories,:lists,{:pages=>[:page_template,{:illustration_crop=>{:illustration=>[:illustrators, :photographers]}}]}]).order("pages.position ASC").order("story_category_id").find(params[:id])
    sim_stories = @story.similar(fields: [:language , :reading_level, :categories], where: {status: "published", language: @story.language.name, reading_level: @story.reading_level}, limit: 12, order: {_score: :desc}, operator: "and", load: false).results
    obj = Search::Books.new({}, nil, false)
    similar_stories = sim_stories
    if(@story.recommendations)
      recommendations = @story.recommendations.split(",").map{|i| i.to_i}
      recommended_obj = Story.search '*', where: {id: recommendations}, load: false, execute: false
      recommended_stories = recommended_obj.execute
      similar_stories = recommended_stories.results + sim_stories
    end    
    @similar_stories = similar_stories.map{|s| obj.sanitize_search_results_for_api(s)}
    @story_other_version = @story.other_versions_api
    @uniq_languages = @story.other_versions_api.collect(&:language).uniq.count
    @lists = @story.lists.where(status: List.statuses["published"])
    show_permissions
  rescue ActiveRecord::RecordNotFound 
    resource_not_found  
  end

  def respond_to_show
    render "show"
  end

  #GET books/filters
  def filters
    languages = Language.published_languages.map{|l| {:name => l.translated_name, :queryValue => l.name}}
    organizations = Organization.story_publishers.map{|o| {:name => o.translated_name, :queryValue => o.organization_name}}
    categories = StoryCategory.all.map{|c| {:name => c.translated_name, :queryValue => c.name}}
    levels = Story.reading_levels.map{|k, v| {:name=> I18n.t("levels."+"Level #{k}"), :queryValue => (v+1).to_s, :description => Story::READING_LEVEL_INFO[k]}}
    language_filter = {:name => "Language", :queryKey => "language", :sourceLanguage => "English", :targetLanguage => "", :queryValues => languages}
    organization_filter = {:name => "Publisher", :queryKey => "publisher", :queryValues => organizations}
    category_filter = {:name => "Category", :queryKey => "category", :queryValues => categories}
    level_filter = {:name => "Level", :queryKey => "level", :queryValues => levels}
    results = {:language => language_filter, :publisher => organization_filter, :category => category_filter, :level => level_filter}
    # results = {:filters => [language_filter, publisher_filter, category_filter, level_filter]}
    sort_options = [{ "name"=> "Most Liked", "queryValue"=> "likes" }, { "name"=> "Most Viewed", "queryValue"=> "views" }, { "name"=> "New Arrivals", "queryValue"=> "published_at" }]
    render json: {"ok"=>true, "data"=> results, :sortOptions => sort_options}
  end
  
  #GET books/translate-filters
  def translate_filters
    source_languages = Language.published_languages.map{|l| {:name => l.translated_name, :queryValue => l.name}}
    target_languages = Language.all.map{|l| {:name => l.translated_name, :queryValue => l.name}}
    organizations = Organization.story_publishers.map{|o| {:name => I18n.t("publishers."+o.organization_name), :queryValue => o.organization_name}}
    categories = StoryCategory.all.map{|c| {:name => c.translated_name, :queryValue => c.name}}
    levels = Story.reading_levels.map{|k, v| {:name=> I18n.t("levels."+"Level #{k}"), :queryValue => (v+1).to_s, :description => Story::READING_LEVEL_INFO[k]}}
    language_filter = {:name => "Language", :queryKey => "language", :sourceLanguage => "English", :targetLanguage => "", :sourceQueryValues => source_languages, :targetQueryValues => target_languages}
    organization_filter = {:name => "Publisher", :queryKey => "publisher", :queryValues => organizations}
    category_filter = {:name => "Category", :queryKey => "category", :queryValues => categories}
    level_filter = {:name => "Level", :queryKey => "level", :queryValues => levels}
    results = {:language => language_filter, :publisher => organization_filter, :category => category_filter, :level => level_filter}
    sort_options = [{ "name"=> "Most Liked", "queryValue"=> "likes" }, { "name"=> "Most Viewed", "queryValue"=> "views" }, { "name"=> "New Arrivals", "queryValue"=> "published_at" }]
    render json: {"ok"=>true, "data"=> results, :sortOptions => sort_options}
  end

  #POST stories/:id/like
  def story_like
    story = Story.find(params[:id])
    if(!(current_user.voted_for? story))
      story.liked_by current_user
      story.reindex
    end
    render json: {"ok"=>true}
  rescue ActiveRecord::RecordNotFound 
    resource_not_found   
  end

  #DELETE stories/:id/like
  def story_unlike
    story = Story.find(params[:id])
    if(current_user.voted_for? story)
      story.unliked_by current_user
      story.reindex
    end 
    render json: {"ok"=>true}
  rescue ActiveRecord::RecordNotFound 
    resource_not_found 
  end

  def flag_story
    story = Story.find(params[:id])
    if current_user.flagged?(story)
      render json: {"ok"=> false, "data" => {"errorCode" => 422, "errorMessage" => "User had already flagged this story."}}, status: 422
    elsif is_reason_empty
      render json: {"ok"=> false, "data" => {"errorCode" => 400, "errorMessage" => "Reason cannot be empty"}}, status: 400
    else
      params[:reasons].delete_if {|x| x=="other"}
      reasons = params[:reasons].join(", ")
      if(params[:otherReason])
        reasons << ", "+params[:otherReason]
      end
      current_user.flag(story, reasons)
      story.reindex
      content_managers=User.content_manager.collect(&:email).join(",")
      UserMailer.delay(:queue=>"mailer").flagged_story(content_managers,story,current_user,reasons,"")
      render json: {"ok"=> true}, status: 200
    end
  end

  #GET api/v1/stories/:id/read
  def story_read
    begin
      @story = Story.find(params[:id])      
      @page = @story.front_cover_page
    rescue Exception
      @story = nil
    end
    @additional_illustration_license_types = if @story.license_type == "Public Domain"
                                               @story.illustration_license_types.reject{|license| license == 'Public Domain'}
                                             else
                                               @story.illustration_license_types.reject{|license| license == 'CC BY 4.0' || license == 'CC BY 3.0'}
                                             end
    @disable_review_link = params[:disable_review_link] if params[:disable_review_link].present?
    if @story
      render "story_read"
      @story.increment!(:reads)
      StoryRead.save_story_read(current_user, @story) if (current_user && @story.published?)
      (session[:reads] ||= []) << @story.id
    else
      render json: {"ok"=>true}
    end
  end

  #POST api/v1/stories/:id/add_to_editor_picks
  def add_to_editor_picks
    if !current_user.content_manager?
      user_not_authorized
    else
      story = Story.find_by_id(params[:id].to_i)
      if story.nil?
        resource_not_found
      elsif !story.recommendation
        recommendation = Recommendation.new
        recommendation.recommendable = story
        recommendation.save!
        story.update_column(:editor_recommended, true)
        story.reindex
        render json: {"ok"=>true}
      else
        render json: {"ok"=>true, "data"=>"Story has already added to editor picks"}
      end
    end
  end

  #POST api/v1/stories/:id/remove_from_editor_picks
  def remove_from_editor_picks
    if !current_user.content_manager?
      user_not_authorized
    else
      story = Story.find_by_id(params[:id].to_i)
      if story.nil?
        resource_not_found
      elsif story.recommendation
        story.recommendation.destroy
        story.update_column(:editor_recommended, false)
        story.reindex
        render json: {"ok"=>true}
      else
        render json: {"ok"=>true, "data"=>"Story has already removed from editor picks"}
      end
    end
  end

  private
  def show_permissions
    if(user_signed_in?)
      authorize(@story, :show?) ? respond_to_show : resource_not_found
    elsif (@story.published?)
      respond_to_show 
    elsif (@story.draft? || @story.uploaded? || @story.edit_in_progress? || @story.de_activated? || @story.submitted?)
      authenticate_user!
    else
      resource_not_found
    end
  end

  def is_reason_empty
    (params[:reasons].nil? || params[:reasons].empty?) || 
    (params[:reasons].delete_if {|x| x=="other"}.empty? &&
      (params[:otherReason].nil? || params[:otherReason].strip==""))
  end
end
