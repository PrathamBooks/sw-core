class Api::V1::SearchController < Api::V1::ApplicationController

  respond_to :json
  EVERYTHING = "*"
  PER_PAGE = 10
  DEFAULT_CRITERIA = [
    { _score: {order: :desc} },
    { recommended_status: {order: :asc, ignore_unmapped: true} },
    { reads: {order: :desc} },
    { likes: {order: :desc} }
  ]

# /api/v1/books-search
  def books_search
    common_params = {
      search: {
      }, 
      page: params[:page], 
      per_page: params[:per_page]
    }

    if params[:cache].present?
      common_params[:search].merge!(:cache => params[:cache])
    end
    if params[:query].present?
      common_params[:search].merge!(:query => params[:query])
    end
    # in search, tags will be part of filter and not query
    if params[:tags].present?
      common_params[:search].merge!(:tags => params[:tags])
    end
    if params[:publishers].present?
      common_params[:search].merge!(:organizations => params[:publishers])
    end
    if params[:languages].present?
      common_params[:search].merge!(:languages => params[:languages])
    end
    if params[:levels].present?
      common_params[:search].merge!(:reading_levels => params[:levels])
    end
    if params[:categories].present?
      common_params[:search].merge!(:categories => params[:categories])
    end
    if params[:sort].present?
      if params[:sort]=="Most Read"
        common_params[:search].merge!(:sort => {reads: {order: :desc}})
      elsif params[:sort]=="Most Liked"
        common_params[:search].merge!(:sort => {likes: {order: :desc}})
      elsif params[:sort]=="New Arrivals" || params[:sort] == "Editor's Picks"
        common_params[:search].merge!(:sort => {published_at: {order: :desc}})
      end
    end
    
    search_obj = Search::Books.new(common_params, current_user, false)

    if(params[:sort].present? && params[:sort] == "Editor's Picks")
      results = search_obj.editor_recommended_stories
    else
      results = search_obj.search
    end

    if results
      render json: {"ok"=>true, "metadata" => results[:metadata], "data"=> results[:search_results]}
    else
      render json: {"ok"=>true, "message" => "No results found"}
    end                              
  end

# /api/v1/lists-search
  def lists_search
    list_params = ActionController::Parameters.new({
      search: {
        query: params[:query],
        status: ["published"]
      }, 
      page: params[:page], 
      per_page: params[:per_page]
    })

    if params[:categories].present?
      list_params[:search].merge!(:categories => params[:categories])
    end
    if params[:sort].present?
      if params[:sort]=="Most Viewed"
        list_params[:search].merge!(:sort => {views: {order: :desc}})
      elsif params[:sort]=="Most Liked"
        list_params[:search].merge!(:sort => {likes: {order: :desc}})
      elsif params[:sort]=="New Arrivals"
        list_params[:search].merge!(:sort => {created_at: {order: :desc}})
      end
    end

    list_search_params = list_params["search"]

    # send the session only when we need to randomize the results
    # randomization should be done when no filter/options are applied
    if ( list_search_params["sort"].blank? && 
         list_search_params["categories"].blank? &&
         list_search_params["query"].blank? )
      curr_session = session
    end
    search_obj = Search::Lists.new(list_params, nil, false, curr_session)
    results = search_obj.general_search

    if results
      render json: {"ok"=>true, "metadata" => results[:metadata], "data"=> results[:search_results]}
    else
      render json: {"ok"=>true, "message" => "No results found"}
    end  
  end

  def illustrations_search
    common_params = ActionController::Parameters.new({
      search: {
        image_mode: "false" # hiding private images for normal users
      },
      content_manager: (current_user.present? && current_user.content_manager?),
      is_organization_cm: current_user.present? && (current_user.organization? || current_user.content_manager?), 
      page: params[:page], 
      per_page: params[:per_page]
    })

    if params[:query].present?
      common_params[:search].merge!(:query => params[:query])
    end
    if params[:tags].present?
      common_params[:search].merge!(:tags => params[:tags])
    end
    if params[:publishers].present?
      common_params[:search].merge!(:organization => params[:publishers])
    end
    if params[:categories].present?
      common_params[:search].merge!(:categories => params[:categories])
    end
    if params[:styles].present?
      common_params[:search].merge!(:styles => params[:styles])
    end
    if params[:illustrators].present?
      common_params[:search].merge!(:illustrator_slugs => params[:illustrators])
    end
    if params[:search].present? && params[:search][:illustrator_slugs].present?
      common_params[:search].merge!(:illustrator_slugs => params[:search][:illustrator_slugs])
    end

    if params[:sort].present?
      if params[:sort]=="Most Viewed"
        common_params[:search].merge!(:sort => {reads: {order: :desc}})
      elsif params[:sort]=="Most Liked"
        common_params[:search].merge!(:sort => {likes: {order: :desc}})
      elsif params[:sort]=="New Arrivals"
        common_params[:search].merge!(:sort => {created_at: {order: "desc"}})
      end
    end

    s = Search::Illustrations.search(common_params)
    illus =  s.results
    search_results = illus.map { |result| sanitize_search_results_for_api(result) }
      metadata= {
      hits:         illus.total_count,
      perPage:     illus.per_page,
      page:         illus.current_page,
      totalPages:  illus.total_pages
    }

    if search_results
      render json: {"ok"=>true, "metadata" => metadata, "data"=> search_results}
    else
      render json: {"ok"=>true, "message" => "No results found"}
    end 
  end

  #GET /api/v1/people-search
  def people_search
    per_page = params[:per_page] || 20
    page = params[:page] || 1
    query = params[:query] || "*"
    
    user_search = User.search(query, where: {_or: [{stories_count: {gte: 1}}, {illustrations_count: {gte: 1}}]}, 
                              match: :word_start, misspellings: {below: 2}, load: false, execute: false, 
                              page: page, per_page: per_page)
    user_results = user_search.execute
    
    results = user_results.map{|u| sanitize_search_results_for_people_search(u)}
    metadata = {
              hits:       user_results.total_count,
              perPage:    user_results.per_page,
              page:       user_results.current_page,
              totalPages: user_results.total_pages
              }
    if results
      render json: {"ok"=>true, "metadata" =>metadata, "data"=> results}
    else 
      render json: {"ok"=>true, "message" => "No results found"}
    end
  end
  
  def sanitize_search_results_for_people_search(result)
    sanitized_response = {}
    sanitized_response["id"] = result["id"]
    sanitized_response["name"] = result["name"]
    sanitized_response["slug"] = result["slug"]
    sanitized_response["type"] = result["type"]
    sanitized_response["profileImage"] = result["profile_image"]
    sanitized_response
  end

  #GET /api/v1/org-search
  def org_search
    per_page = params[:per_page] || 20
    page = params[:page] || 1
    query = params[:query] || "*"
    
    org_search = Organization.search(query, where: {_or: [{stories_count: {gte: 1}}, {illustrations_count: {gte: 1}}, {media_count: {gte: 1}}]},
                                     match: :word_start, misspellings: {below: 2}, load: false, execute: false, 
                                     page: page, per_page: per_page)
    org_results = org_search.execute
    
    results = org_results.map{|o| sanitize_search_results_for_org_search(o)}
    metadata = {
              hits:       org_results.total_count,
              perPage:    org_results.per_page,
              page:       org_results.current_page,
              totalPages: org_results.total_pages
              }
    if results
      render json: {"ok"=>true, "metadata" =>metadata, "data"=> results}
    else 
      render json: {"ok"=>true, "message" => "No results found"}
    end
  end

  def sanitize_search_results_for_org_search(result)
    sanitized_response = {}
    sanitized_response["id"] = result["id"]
    sanitized_response["name"] = result["organization_name"]
    sanitized_response["slug"] = result["slug"]
    sanitized_response["type"] = (result["organization_type"] == "Publisher") ? "publisher" : "organisation"
    sanitized_response["profileImage"] = result["logo"]
    sanitized_response
  end



  def sanitize_search_results_for_api(result)
    sanitized_response = {}
    sanitized_response["id"] = result["id"]
    sanitized_response["title"] = result["name"]
    sanitized_response["slug"] = result["url_slug"]
    sanitized_response["count"] = 1
    sanitized_response["illustrators"] = result["illustrator_details"] 
    if(result["organization"] != "")
      sanitized_response["publisher"]= {}
      sanitized_response["publisher"]["name"] = result["organization"]
      sanitized_response["publisher"]["slug"] = result["publisher_slug"]
    else
      sanitized_response["publisher"] = nil
    end
    sanitized_response["imageUrls"] = [{}]
    sanitized_response["imageUrls"][0]["aspectRatio"] = 320.0/240.0
    sanitized_response["imageUrls"][0]["cropCoords"] = result["crop_coords"]
    sanitized_response["imageUrls"][0]["sizes"] = result["image_sizes"]
    sanitized_response["likesCount"] = result["likes"]
    sanitized_response["readsCount"] = result["reads"]
    sanitized_response
  end

  def books_for_translation
    common_params = {search: {reading_levels: (params[:reading_levels] if params[:reading_levels]),
                              languages: [params[:source_language]], target_languages: [params[:target_language]],
                              categories: (params[:categories] if params[:categories]),
                              organizations: (params[:publishers] if params[:publishers]),
                              sort: {reads: {order: "desc"}}}, page: params[:page], per_page: params[:per_page], books_for_translation: true}

    nObj = Search::Books.new(common_params, nil, false)
    results = nObj.search

    if results
      metadata = results[:metadata]
      results = results[:search_results]
      render json: {"ok"=>true, "metadata" => metadata, "data"=> results}
    else
      render json: {"ok"=>true, "message" => "No results found"}
    end
  end

  #/api/v1/category-banner
  def category_banner
    @category = StoryCategory.find_by_name(params[:name])
  rescue ActiveRecord::RecordNotFound 
    resource_not_found  
  end

end
