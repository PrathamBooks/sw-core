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
    if params[:story_type].present?
      common_params[:search].merge!(:story_type => params[:story_type])
    end
    if params[:publishers].present?
      if params[:publishers].include?("Child Created")
        common_params[:search].merge!(:child_created => "Child Created")
        params[:publishers].delete("Child Created")
      end
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
        common_params[:search].merge!(:sort => {likes_and_good_ratings: {order: :desc}})
      elsif params[:sort]=="New Arrivals" || params[:sort] == "Editor's Picks"
        common_params[:search].merge!(:sort => {published_at: {order: :desc}})
      elsif current_user && current_user.content_manager? && params[:sort] == "Ratings"
        common_params[:search].merge!(:sort => {rating: {order: :desc}})
      end
    end
    if current_user && current_user.content_manager?
      if params[:status].present?
        common_params[:search].merge!(:status => params[:status]) unless params[:status].include?("All Stories")
        common_params[:search].merge!(:status => ["published", "draft"]) if params[:status].include?("All Stories")
      end
      if params[:derivation_type].present? && !params[:derivation_type].include?("All Stories")
        common_params[:search].merge!(:derivation_type => params[:derivation_type])
      end
    end
    if params[:bulk_download].present? && params[:bulk_download] == "Not Downloaded"
      common_params[:search].merge!(:bulk_download => params[:bulk_download])
    end
    search_obj = Search::Books.new(common_params, current_user, false)

    if(params[:sort].present? && params[:sort] == "Editor's Picks")
      results = search_obj.editor_recommended_stories
    else
      results = search_obj.search
    end   
    metadata = results[:metadata].merge!(total_count_of_all_tabs('books_search', common_params))
    
    if results
      render json: {"ok"=>true, "metadata" => metadata, "data"=> results[:search_results]}
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

    metadata = results[:metadata].merge!(total_count_of_all_tabs('lists_search', list_params))

    if results
      render json: {"ok"=>true, "metadata" => metadata, "data"=> results[:search_results]}
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
    
    if params[:styles].present?
      common_params[:search].merge!(:styles => params[:styles])
    end
    if params[:illustrators].present?
      common_params[:search].merge!(:illustrator_slugs => params[:illustrators])
    end
    if params[:search].present? && params[:search][:illustrator_slugs].present?
      common_params[:search].merge!(:illustrator_slugs => params[:search][:illustrator_slugs])
    end
    if params[:categories].present?
        common_params[:search].merge!(:categories => params[:categories])
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
    unless ( current_user.try(:allow_gif_images) )
      common_params[:no_gif_images] = true
    end

    if current_user
      common_params[:search].merge!(:current_user => current_user)
    end

    if params[:bulk_download].present? && params[:bulk_download] == "Not Downloaded"
      common_params[:search].merge!(:bulk_download => "Not Downloaded")
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

    metadata = metadata.merge!(total_count_of_all_tabs('illustrations_search', common_params))

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
      render json: {"ok"=>true, "metadata" => metadata.merge!(total_count_of_all_tabs('people_search')), "data"=> results}
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
      render json: {"ok"=>true, "metadata" => metadata.merge!(total_count_of_all_tabs('org_search')), "data"=> results}
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
    sanitized_response["illustrationDownloaded"] = current_user ? (result["illustration_downloads"].present? ? result["illustration_downloads"].include?(current_user.id) : false) : false
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

  #/api/v1/confirm_story_formats
  def confirm_story_formats
    story_ids = params[:ids]
    story_ids_with_format = {"HiRes PDF"  => [], "PDF" => []}
    if params[:download_format] == "HiRes PDF"
      story_ids.each do|id|
        story = Story.find(id)
        if current_user && current_user.content_manager?
           story_ids_with_format["HiRes PDF"] << id.to_i
        elsif current_user && (current_user.organization? || current_user.own_stories)
           if story && story_access(story)
            story_ids_with_format["HiRes PDF"] << id.to_i
          else
            story_ids_with_format["PDF"] << id.to_i
          end
        end
      end
      render json: {"ok"=>true, "data" => story_ids_with_format}, status: 200
    else
      render json: {"ok"=>true, "data" => {"PDF" => story_ids}}, status: 200
    end
  end

  def story_access(story)
    if story.is_user_own_story(current_user)
      return true
    elsif (story.organization.present? && current_user.organization?) && (story.organization == current_user.organization)
      return true
    end
  end

  #/api/v1/confirm_illustration_formats
  def confirm_illustration_formats
    image_ids = params[:ids]
    image_ids_with_format = {"HiRes JPEG"  => [], "JPEG" => []}
    if params[:download_format] == "HiRes JPEG"
      image_ids.each do|id|
        image = Illustration.find(id)
        if current_user && current_user.content_manager?
           image_ids_with_format["HiRes JPEG"] << id
        elsif current_user && (current_user.organization? || current_user.person.illustrations.any?)
           if image && image_access(image)
            image_ids_with_format["HiRes JPEG"] << id
          else
            image_ids_with_format["JPEG"] << id
          end
        end
      end
      render json: {"ok"=>true, "data" => image_ids_with_format}, status: 200
    else
      render json: {"ok"=>true, "data" => {"JPEG" => image_ids}}, status: 200
    end
end

def image_access(image)
  if image.illustrators.collect(&:email).join(",") == current_user.email
    return true
  elsif (image.organization.present? && current_user.organization?) && (image.organization == current_user.organization)
    return true
  end
end

  def total_count_of_all_tabs(search_tab, query_params = {})
  if search_tab == "books_search"
    books_params = query_params
  else
    books_params = {
      search: {
        query: params[:query]
      } 
    }
  end
  
  search_obj = Search::Books.new(books_params, current_user, false)
  results = search_obj.search[:metadata][:hits]
  books_count = results
  
  if search_tab == "lists_search"
    list_params = query_params
  else
    list_params = list_params = ActionController::Parameters.new({
      search: {
        query: params[:query],
        status: ["published"]
      }
    })
  end

  list_search_obj = Search::Lists.new(list_params, nil, false, nil)
  lists_count = list_search_obj.general_search[:metadata][:hits]
  
  if search_tab == "illustrations_search"
    illustration_params = query_params
  else
    illustration_params = ActionController::Parameters.new({
      search: {
        query: params[:query],
        image_mode: "false" # hiding private images for normal users
      },
      content_manager: (current_user.present? && current_user.content_manager?),
      is_organization_cm: (current_user.present? && (current_user.organization? || current_user.content_manager?))
    })

    unless ( current_user.try(:allow_gif_images) )
      illustration_params[:no_gif_images] = true
    end

    if current_user
      illustration_params[:search].merge!(:current_user => current_user)
    end
  end
  
  illustration_result = Search::Illustrations.search(illustration_params).results
  illustrations_count = illustration_result.total_count
      
  query = params[:query] || "*"
  user_search = User.search(query, where: {_or: [{stories_count: {gte: 1}}, {illustrations_count: {gte: 1}}]}, 
                            match: :word_start, misspellings: {below: 2}, load: false, execute: false)
  user_results = user_search.execute
  users_count   = user_results.total_count
  
  query = params[:query] || "*"
  org_search = Organization.search(query, where: {_or: [{stories_count: {gte: 1}}, {illustrations_count: {gte: 1}}, {media_count: {gte: 1}}]},
                                   match: :word_start, misspellings: {below: 2}, load: false, execute: false)
  org_results = org_search.execute
  organisation_count   = org_results.total_count
  
  count_hash = { books_count: books_count, illustrations_count: illustrations_count, users_count: users_count, lists_count: lists_count, organisation_count: organisation_count}
  count_hash
  end
  #/api/v1/bulk-download
  include BulkDownload # including lib/bulk_download.rb module.
  def bulk_download
    new_params={}
    ["HiRes PDF", "PDF", "Text Only", "ePub"].each do |format|
      high_resolution = format == "HiRes PDF" ? "true" : "false"
      new_params[format] = {
      high_resolution: high_resolution,
      stories_to_download: params["#{format}"]
    } if params["#{format}"]
    end
    bk_download new_params, current_user, request 
  end

  #/api/v1/image-bulk-download
  include ImageBulkDownload # including lib/image_bulk_download.rb module.
  def image_bulk_download
     new_params={}
    ["HiRes JPEG", "JPEG"].each do |format|
      style = format == "JPEG" ? "large" : "original"
      new_params[format] = {
        images_to_download: params["#{format}"],
        style: style,
        } if params["#{format}"]
    end
    # image_bk_download is in lib/image_bulk_download.rb module.
    image_bk_download new_params, current_user, request
  end
end
