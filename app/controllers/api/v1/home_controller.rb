class Api::V1::HomeController < Api::V1::ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:subscription]

  respond_to :json

  def index

  end

  def me
    if current_user
      @profile_data = current_user.profile
      @profile_data["hasHistory"] = current_user.recommendations.nil? ? false : true
      @profile_data["isLoggedIn"] = true
      @profile_data["locale"] = session[:locale]
      @profile_data["homePopup"] = current_user.phonestories_popup.popup_opened if current_user.phonestories_popup
      @profile_data["popupsSeen"] = current_user.user_popups.pluck(:name)
      @profile_data["offlineBookPopupSeen"] = current_user.offline_book_popup_seen
      @profile_data["language_preferences"] = current_user.language_preferences_list
      @profile_data["reading_levels"] = current_user.reading_levels_list
      @organization = current_user.organization
      @myList = current_user.lists.default_list[0]
      render "me"
    else
      render json: {
        "ok" => true, 
        "data" => {
          "isLoggedIn" => false,
          "locale" => session[:locale] ? session[:locale] : "en"
        }
      }, status: 200
    end
  end

 def user_status
   if params[:email]
      user = User.where('lower(email) = ?', params[:email].strip.downcase).first   # case insensitive search
      render json: {"ok"=>true, "data"=>{"exists"=>(user != nil)}}
   else
     render json: {"ok"=>false, "data"=>{"errorCode"=>403, "errorMessage"=>"Email can not be empty"}}, status: 403
   end

 end

  def get_categories
    render json: StoryCategory.all.map(&:name)
  end

  def subscription
    subscription = Subscription.find_by_email(params[:email])
    if(subscription)
      render json: {"ok"=>false, "data"=>{"errorCode"=>403, "errorMessage"=>"This email is already subscribed"}}, status: 403
    else
      new_subscription = Subscription.create(:email => params[:email])
      if(new_subscription.valid?)
        render json: {"ok" => true}
      else
        render json: {"ok"=>false, "data"=>{"errorCode"=>422, "errorMessage"=>"email id is not valid"}}, status: 422
      end
    end
  end

  def disable_notice
    if(session[:submitted_story_notice] == true)
      session[:submitted_story_notice] = false
      render json: {"ok"=>true}, status: 200
    puts session[:submitted_story_notice]
    else
      render json: {"ok"=>false, "data"=>{"errorCode"=>404, "errorMessage"=>"submitted_story_notice flag not set"}}, status: 404
    end
  end

  def footer_images
    @footer_images = FooterImage.all
  end

  def banners
    @banner_images = Banner.where(:is_active => true).order('position asc')
  end
  #GET /api/v1/home
  def show
    per_page = params[:perPage] ? params[:perPage] : Settings.per_page.entity_count
    params = {search: {reading_levels: ["all"], languages: ["all"],
                      sort: {published_at: {order: "desc"}},
                      cache: "false"}, page: "1", per_page: per_page}
    @banner_images = Banner.where(:is_active => true).order('position asc')
    most_read_params = {search: {reading_levels: ["all"], languages: ["all"],
                      sort: {reads: {order: "desc"}},
                      cache: "false"}, page: "1", per_page: per_page}                      
    gen_obj = Search::Books.new(params, nil, false)
    most_read_obj = Search::Books.new(most_read_params, nil, false)
    @most_read = most_read_obj.search
    @new_arrivals = gen_obj.search
    @editor_picks = gen_obj.editor_recommended_stories
    @blog_posts = BlogPost.limit(2)
                          .where(status: BlogPost.statuses[:published])
                          .where.not(blog_post_image_file_name: nil)
                          .order('published_at desc')
    #Lists
    # Showing one list from the PB and two other random lists.
    pb_list = List.where(status: 1).where(:organization_id => 811).order("RANDOM()").limit(1)
    if(pb_list.any?)
      other_lists = List.where(status: 1).where.not(id: pb_list[0].id).order("RANDOM()").limit(2)
    else
      other_lists = List.where(status: 1).order("RANDOM()").limit(3)
    end
    list_ids = (pb_list + other_lists).map{|s| s.id}
    lObj = List.search '*', where: {id: list_ids}, load: false, execute: false
    lists = lObj.execute
    @lists = lists.map{ |result| sanitize_search_results_for_api_list(result) }
    #statistics
    @stories_count = Story.where(status: Story.statuses[:published]).count
    @reads_count = Story.sum(:reads)
    @languages_count = Language.published_languages.collect(&:name).map{|n| n.split("-")}.flatten.uniq.size
  end

  #GET /api/v1/home/recommendations
  def recommendations
    if(user_signed_in? && !current_user.recommendations.nil?)
      recomm_list = current_user.recommendations.split(",").map{|i| i.to_i}
    else
      recomm_list = Story.where(status: Story.statuses[:published])
                         .joins(:story_reads).where('story_reads.created_at >= ?', 2.weeks.ago)
                         .group('story_reads.story_id').reorder('count_id desc')
                         .limit(Settings.per_page.entity_count).count('id').keys()
    end
    if(session[:recommendations].nil? || session[:recommendations].empty?)
      session[:recommendations] = recomm_list
    end
    #Modifying the recommendations based on the session reads.
    if(!session[:reads].nil?)
      session[:used_reads] ||= []
      to_process_stories = session[:reads].uniq - session[:used_reads]
      to_process_stories.each do |story_id|
        read_story = Story.find(story_id)
        session[:recommendations].delete(story_id) if (session[:recommendations].include? story_id)
        reco_story_id = read_story.recommendations.nil? ? nil : Story.find(story_id).recommendations.split(",")[0].to_i
        next if reco_story_id.nil?
        position = (recomm_list.include? story_id) ? 5 : 0
        session[:recommendations].insert(position,reco_story_id)        
      end
      session[:used_reads].concat(to_process_stories)
    end
    session[:recommendations] = session[:recommendations][0..(Settings.per_page.entity_count-1)]
    search_object = Story.search '*', where: {id: session[:recommendations]}, load: false, execute: false
    stories = search_object.execute
    stories_sorted = stories.sort_by{|s| session[:recommendations].index s.id}
    @recommended_stories =  stories_sorted.map { |result| sanitize_search_results_for_api(result) }
  end
  
  #api/v1/home/categories
  def categories
    @story_categories = StoryCategory.where(active_on_home: true).reorder("RANDOM()").limit(6)
  end

  def sanitize_search_results_for_api(result)
      sanitized_response = {}
      sanitized_response["id"] = result["id"]
      sanitized_response["title"] = result["title"]
      sanitized_response["language"] = result["language"]
      sanitized_response["level"] = result["reading_level"]
      sanitized_response["slug"] = result["url_slug"]
      sanitized_response["recommended"] = result["recommended_status"] == "recommended" || result["recommended_status"] == "home_recommended"
      sanitized_response["editorsPick"] = result["editor_recommended"]
      sanitized_response["coverImage"] = {}
      sanitized_response["coverImage"]["aspectRatio"] = 224.0/224.0
      sanitized_response["coverImage"]["cropCoords"] = result["cover_image_crop_coords"]
      sanitized_response["coverImage"]["sizes"] = result["image_sizes"]
      sanitized_response["authors"] = result["authors_details"]
      illustrator_details = []
      result["illustrators"].each_with_index do |name, i|
        illustrator_details.append({:name=>name, :slug=>result["illustrator_slugs"][i]})
      end
      sanitized_response["illustrators"] = illustrator_details
      sanitized_response["readsCount"] = result["reads"]
      sanitized_response["likesCount"] = result["likes"]
      sanitized_response["description"] = result["synopsis"]
      sanitized_response["publisher"] = {:name=>result["organization"].empty? ? "StoryWeaver Community" : result["organization"],
                                         :slug=>result["organization"].empty? ? nil : result["organization_slug"],
                                         :logo=>result["organization_logo"]}

      if(result["contest"])
        sanitized_response["contest"] = {}
        sanitized_response["contest"]["name"] = result["contest_name"]
        sanitized_response["contest"]["slug"] = result["contest_slug"]
        sanitized_response["contest"]["won"] = result["winner"]
      else
        sanitized_response["contest"] = nil
      end
      sanitized_response["availableForOfflineMode"] = result["availableForOfflineMode"]      
    sanitized_response
  end

  def sanitize_search_results_for_api_list(result)
      sanitized_response = {}
      sanitized_response["title"] = result["title"]
      sanitized_response["id"] = result["id"]
      sanitized_response["count"] = result["count"]
      sanitized_response["description"] = result["description"]
      sanitized_response["slug"] = result["slug"]
      sanitized_response["categories"] = result["categories"]
      sanitized_response["likes"] = result["likes"]
      sanitized_response["views"] = result["views"]
      sanitized_response["author"] = {}
      sanitized_response["author"]["id"] = result["author_id"]
      sanitized_response["author"]["slug"] = result["author_slug"]
      sanitized_response["author"]["name"] = result["author"]
      sanitized_response["organisation"] = {}
      sanitized_response["organisation"]["id"] = result["organization_id"]
      sanitized_response["organisation"]["slug"] = result["organization_slug"]
      sanitized_response["organisation"]["name"] = result["organization_name"]
      sanitized_response["organisation"]["type"] = result["organization_id"].nil? ? nil : ((result["organization_type"] == "Publisher") ? "publisher" : "organisation")
      sanitized_response["organisation"]["profileImage"] = result["organization_profile_image"]
      sanitized_response["count"] = result["count"]
      sanitized_response["books"] = result["books"]
      sanitized_response["languages"] = result["languages"]
      sanitized_response["levels"] = result["reading_levels"]
      sanitized_response["canDelete"] = result["can_delete"]
      sanitized_response
  end

end
