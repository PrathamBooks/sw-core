class Api::V1::StoriesController < Api::V1::ApplicationController
  
  before_action :authenticate_user!, only: [:flag_story, :add_to_editor_picks, :remove_from_editor_picks, :story_like]
  before_action :set_story, only: [:story_like, :flag_story]
  respond_to :json
  def show
    @story = Story.eager_load([:language,:authors,:organization,:categories,:lists,{:pages=>[:page_template,{:illustration_crop=>{:illustration=>[:illustrators, :photographers]}}]}]).order("pages.position ASC").order("story_category_id").find(params[:id])
    sim_stories = @story.similar(fields: [:language , :reading_level, :categories], where: {status: "published", language: @story.language.name, reading_level: @story.reading_level, organization: {not: ""}}, limit: 50, order: {_score: :desc}, operator: "and", load: false).results
    obj = Search::Books.new({}, nil, false)
    similar_stories = sim_stories
    if(@story.recommendations)
      recommendations = @story.recommendations.split(",").map{|i| i.to_i}
      recommended_obj = Story.search '*', where: {id: recommendations}, load: false, execute: false
      recommended_stories = recommended_obj.execute
      similar_stories = sim_stories + recommended_stories.results
    end    
    @similar_stories = similar_stories.map{|s| obj.sanitize_search_results_for_api(s)}
    @similar_stories.delete_if { |s| s["id"] == @story.id }
    if current_user
      @similar_stories.map do |story|
        if current_user.read_stories != nil ? current_user.read_stories.include?(story["id"].to_s) : false
          @similar_stories.delete_if { |s| s["id"] == story["id"] }
          @similar_stories << story
        end
      end
    else
     if session["read_stories"].present?
      @similar_stories.map do |story|
        if session["read_stories"].include?(story["id"].to_s)
          @similar_stories.delete_if { |s| s["id"] == story["id"] }
          @similar_stories << story
        end
      end
     end
    end
    @story_other_version = @story.other_versions_api
    @uniq_languages = @story.other_versions_api.collect(&:language).uniq.count
    @lists = @story.lists
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
    get_all_filters(:queryValues => languages)
  end

  def download_type(type)
    if type == "PDF" || type == "ePub"
      return true
    elsif type == "HiRes PDF" || type == "Text Only"
      if current_user.content_manager? || current_user.organization?
        return true
      else
        return current_user.own_stories
      end
    end
  end
  
  #GET books/translate-filters
  def translate_filters
    source_languages = Language.published_languages.map{|l| {:name => l.translated_name, :queryValue => l.name}}
    target_languages = Language.all.map{|l| {:name => l.translated_name, :queryValue => l.name}}
    get_all_filters(:sourceQueryValues => source_languages, :targetQueryValues => target_languages)
  end

  def get_all_filters(languages)
    organizations = Organization.story_publishers.map{|o| {:name => o.translated_name, :queryValue => o.organization_name}}
    organizations << {:name => I18n.t("publishers.Created by Children"), :queryValue => "Child Created"} if current_user && current_user.content_manager?
    organizations << {:name => I18n.t("publishers.StoryWeaver Community"), :queryValue => "storyweaver"} if current_user && current_user.content_manager?
    categories = StoryCategory.with_translations(I18n.locale).not_readalong.private_category(current_user).map{|c| {:name => c.translated_name, :queryValue => c.name}}
    levels = Story.reading_levels.map{|k, v| {:name=> I18n.t("levels."+"Level #{k}"), :queryValue => (v+1).to_s, :description => Story::READING_LEVEL_INFO[k]}}
    derivation_type = [{:name => I18n.t("derivation_type.All Story Types"), :queryValue => "All Stories"}, {:name => I18n.t("derivation_type.Original"), :queryValue => "nil"}, {:name => I18n.t("derivation_type.Translation"), :queryValue => "translated"}, {:name => I18n.t("derivation_type.Re-level"), :queryValue => "relevelled"}]
    story_status = [{:name => I18n.t("status.All Stories"), :queryValue => "All Stories"}, {:name => I18n.t("status.Published"), :queryValue => "published"}, {:name => I18n.t("status.Draft"), :queryValue => "draft"}]
    story_type = [{:name => I18n.t("story_type.read"), :queryValue => "read"}, {:name => I18n.t("story_type.audio"), :queryValue => "audio"}, {:name => I18n.t('story_type.gif'), :queryValue => 'gif'}]
    language_filter = {:name => "Language", :queryKey => "language", :sourceLanguage => "English", :targetLanguage => ""}.merge!(languages)
    organization_filter = {:name => "Publisher", :queryKey => "publisher", :queryValues => organizations}
    category_filter = {:name => "Category", :queryKey => "category", :queryValues => categories}
    level_filter = {:name => "Level", :queryKey => "level", :queryValues => levels}
    derivation_type_filter = {:name => "Derivation Type", :queryValue => "derivation_type", :queryValues => derivation_type}
    status_filter = {:name => "Story Status", :queryValue => "status", :queryValues => story_status}
    story_type_filter = {:name => "Story Type", :queryValue => "story_type", :queryValues => story_type}
    results = {:language => language_filter, :publisher => organization_filter, :category => category_filter, :level => level_filter, :derivation_type => derivation_type_filter, :status => status_filter, :story_type => story_type_filter}
    # results = {:filters => [language_filter, publisher_filter, category_filter, level_filter]}
    sort_options = [{ "name"=> "Most Liked", "queryValue"=> "likes" }, { "name"=> "Most Viewed", "queryValue"=> "views" }, { "name"=> "New Arrivals", "queryValue"=> "published_at" }]
    download_filter = ["PDF", "ePub", "Text Only", "HiRes PDF"].map{|type| {:name => I18n.t("download_link."+type), :queryValue => type}  if current_user && download_type(type) }.compact
    render json: {"ok"=>true, "data"=> results, :sortOptions => sort_options, :downloadType =>  download_filter.unshift({:name => I18n.t("download_link.Select Format"), :queryValue => ''})}
  end

  #GET /stories/:id/translate_recommendations
  def translate_recommendations
    @story = Story.find_by_id(params[:id])
    if @story.nil?
      render json: {"ok"=> false, "data" => {"errorCode" => 400, "errorMessage" => "Story not found"}}, status: 400
      return
    end
    common_params = {search: {languages: [@story.language.name], target_languages: [params[:translateToLanguage] || ""],sort: {reads: {order: "desc"}}}, page: 1, per_page: Settings.per_page.entity_count + 1, books_for_translation: true}
    nObj = Search::Books.new(common_params, nil, false)
    results = nObj.search
    @similar_stories = results[:search_results]
    if(@similar_stories.length < Settings.per_page.entity_count)
      recommended_obj = Story.search '*', where: {language: "English", status: :published}, order: {reads: :desc}, load: false, execute: false
      recommended_stories = recommended_obj.execute
      obj = Search::Books.new({}, nil, false)
      @similar_stories = @similar_stories + recommended_stories.results.map{|s| obj.sanitize_search_results_for_api(s)}
    end
    @similar_stories.delete_if { |s| s["id"] == @story.id }
  end

  #POST stories/:id/like
  def story_like
    if(!(current_user.voted_for? @story))
      @story.liked_by current_user
      @story.reindex
    end
    render json: {"ok"=>true}
  rescue ActiveRecord::RecordNotFound
    resource_not_found
  end

  def flag_story
    if current_user.flagged?(@story)
      render json: {"ok"=> false, "data" => {"errorCode" => 422, "errorMessage" => "User had already flagged this story."}}, status: 422
    elsif is_reason_empty
      render json: {"ok"=> false, "data" => {"errorCode" => 400, "errorMessage" => "Reason cannot be empty"}}, status: 400
    else
      params[:reasons].delete_if {|x| x=="other"}
      reasons = params[:reasons].join(", ")
      if(params[:otherReason])
        reasons << ", "+params[:otherReason]
      end
      current_user.flag(@story, reasons)
      @story.reindex
      content_managers=User.content_manager.collect(&:email).join(",")
      UserMailer.delay(:queue=>"mailer").flagged_story(content_managers,@story,current_user,reasons,"")
      render json: {"ok"=> true}, status: 200
    end
  end

  #GET api/v1/stories/:id/read
  def story_read
    begin
      @story = Story.find(params[:id])      
      @page = @story.front_cover_page
      @additional_illustration_license_types = if @story.license_type == "Public Domain"
                                               @story.illustration_license_types.reject{|license| license == 'Public Domain'}
                                             else
                                               @story.illustration_license_types.reject{|license| license == 'CC BY 4.0' || license == 'CC BY 3.0'}
                                             end
      @disable_review_link = params[:disable_review_link] if params[:disable_review_link].present?
      if current_user
        if current_user.read_stories.nil?
          current_user.read_stories =  @story.id.to_s
        else
          current_user.read_stories = current_user.read_stories+", "+@story.id.to_s unless current_user.read_stories.include?(@story.id.to_s)
        end
        current_user.save!
      else
        if session["read_stories"].present?
          unless session["read_stories"].include?(@story.id.to_s)
            session["read_stories"] << @story.id.to_s
          end
        else
          session["read_stories"] = [@story.id.to_s]
        end
      end
   
      render "story_read"
      @story.increment!(:reads)
      story_read_type = params[:isAudio] ? :audio : :read
      StoryRead.save_story_read(current_user, @story, story_read_type) if (current_user && @story.published?)
      (session[:reads] ||= []) << @story.id
    rescue ActiveRecord::RecordNotFound 
      resource_not_found
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

  def smiley_ratings
    @story = Story.find(params[:storySlug])
    if current_user
      save_smiley_rating(@story, params[:reaction]) unless current_user.smiley_ratings.where(:story_id => @story.id).present?
      render json: {"ok"=>true}
    else
      unless @story.smiley_ratings.where(:session_id => session.id).present?
        save_smiley_rating(@story, params[:reaction], request.session.id)
      end
      render json: {"ok"=>true}
    end
  end

  def save_smiley_rating(story, reaction, session_id = nil)
    smiley_rating = SmileyRating.new
    smiley_rating.story_id = story.id
    smiley_rating.user_id = current_user ? current_user.id : nil
    smiley_rating.reaction = reaction
    smiley_rating.session_id = session_id
    smiley_rating.save!
    story.reindex
  end

  def update_story_level
    @story = Story.find_by_id(params[:id])
    if @story.blank? || @story.is_derivation? || params[:newLevel].blank?
      render json: {"ok"=> false, "data" => {"errorCode" => 400, "errorMessage" => "Story cannot be relevelled"}}, status: 400
    else
      @story.update_attributes(:reading_level => params[:newLevel])
      @story.reindex
      @translated_stories = @story.descendants.where(:derivation_type => "translated")
      @translated_stories.update_all(reading_level: Story.reading_levels[params[:newLevel]])
      @translated_stories.map{|s| s.reindex}
      render json: {"ok"=>true}
    end
  end

  def check_translations
    @story = Story.find_by_id(params[:id])
    if @story.blank? || params[:translateToLanguage].blank?
      render json: {"ok"=> false, "data" => {"errorCode" => 400}, status: 400}
    else
      @translate_to_language = Language.find_by_name(params[:translateToLanguage])
      @translated_stories = @story.root.descendants.where(:derivation_type => "translated", language: @translate_to_language, :status => Story.statuses[:published] ).pluck(:id)
      @translated_stories << @story.root.id if @story.root.language == @translate_to_language
      render json: {"ok"=>true, "data"=> @translated_stories}
    end
  end

  private
  def set_story
    @story = Story.find(params[:id])
  end

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
