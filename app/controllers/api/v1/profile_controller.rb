class Api::V1::ProfileController < Api::V1::ApplicationController

  before_action :authenticate_user!, only: [:edit_user_details, :edit_org_details, :set_offline_book_popup_seen]
  respond_to :json

  #GET /api/v1/users/:id
  def user_details
    @user = User.find(params[:id])
    per_page = params[:perPage] ? params[:perPage] : 20
    params_search = {
      reading_levels: ['all'],
      languages: ['all'],
      authors: @user.name,
      sort: {
        published_at: {
          order: "desc"
        }
      },
      cache: "false"
    }
    
    search = params_search.merge!({ derivation_type: ['nil'] })
    params = { search: search, page: "1", per_page: "1000" }
    sObj = Search::Books.new(params, nil, false)
    @user_stories = sObj.search
    
    translation_search = params_search.merge!({ derivation_type: ['translated'] })
    translation_params = { search: translation_search, page: "1", per_page: "1000" }
    tObj = Search::Books.new(translation_params, nil, false)
    @user_translated_stories = tObj.search
    
    relevelled_search = params_search.merge!({derivation_type: ['relevelled']})
    relevelled_params = { search: relevelled_search, page: "1", per_page: "1000" }
    relevelled_objects = Search::Books.new( relevelled_params, nil, false )
    @user_relevelled_stories = relevelled_objects.search
    
    illustrator = @user.person
    if(!illustrator.nil?)
      illus_params = ActionController::Parameters.new({search: {illustrator_slugs: "#{@user.slug}", image_mode: "false"}, page: "1", per_page: per_page})
      iObj = Search::Illustrations.search(illus_params)
      illus = iObj.results
      @user_illustrations = illus.map { |result| sanitize_search_results_for_api(result)}
      @illus_metadata= {
        hits:         illus.total_count,
        perPage:     illus.per_page,
        page:         illus.current_page,
        totalPages:  illus.total_pages
      }
    else
      @user_illustrations = []
      @illus_metadata = {
        hits:         0,
        perPage:     per_page,
        page:         1,
        totalPages:  0
      }
    end
    list_params = ActionController::Parameters.new({search: {reading_levels: ["all"], author_id: @user.id, min_story_count: 1}, page: "1", per_page: "1000"})
    lObj = Search::Lists.new(list_params, nil, false, nil)
    @user_lists = lObj.search
    @media_mentions = @user.media_mentions
    @media_mentions_metadata = {
      hits:         @media_mentions.count,
      perPage:       100,
      page:          1,
      totalPages:    1
    }
    if(@user.organization_id)
      @user_org = Organization.find(@user.organization_id.to_i)
      @user_org_type = (@user_org.organization_type && @user_org.organization_type == "Publisher") ?  "PUBLISHER" : "ORGANISATION"
    else
      @user_org = nil
    end
  end

  #GET /api/v1/organisations/:id
  def org_details
    @org = Organization.find(params[:id])
    per_page = params[:perPage] ? params[:perPage] : 20
    page = params[:page] ? params[:page] : 1   
    org_linker = @org.organization_type ? ((@org.organization_type == "Publisher") ? "publishers" : "organisations") : "organisations"
    if(request.path != "/api/v1/#{org_linker}/#{params[:id]}")
      resource_not_found
    end
    @org_type = (@org.organization_type && @org.organization_type == "Publisher") ? "PUBLISHER" : "ORGANISATION"
    list_params = ActionController::Parameters.new({search: {reading_levels: ["all"], organization_id: @org.id, min_story_count: 1}, page: "1", per_page: "1000"})
    lObj = Search::Lists.new(list_params, nil, false, nil)
    @org_lists = lObj.search
    @media_mentions = @org.media_mentions
    @media_mentions_metadata = {
      hits:         @media_mentions.count,
      perPage:       100,
      page:          1,
      totalPages:    1
    }
    params = {search: {reading_levels: ["all"], languages: ["all"], 
                      organizations: [@org.organization_name],
                      sort: {published_at: {order: "desc"}},
                      cache: "false"}, page: page, per_page: per_page}
    nObj = Search::Books.new(params, nil, false)
    @new_arrivals = nObj.search
    eObj = Search::Books.new(params, nil, false)
    @editor_recommendations = eObj.editor_recommended_stories

  rescue ActiveRecord::RecordNotFound 
    resource_not_found
  end

  def edit_user_details   
    id = params[:id].to_i
    name = params[:name]
    description = params[:description]
    website = params[:website]
    profileImage = params[:profileImage]

    if(id != current_user.id)
      render json: {"ok"=>false, "data"=>{"errorCode"=>403, "errorMessage"=>"Unauthorized user."}}, status: 403
    end

    @user = User.find(id)
    if(name && name != @user.name)
      @user.name = name
    end
    if(description && description != @user.bio)
      @user.bio = description
    end
    if(website && website != @user.website)
      @user.website = website  
    end
    if(profileImage && profileImage != @user.profile_image)
      @user.profile_image = profileImage
    end
    @user.save!   
  end
  
  def edit_org_details    
    id = params[:id].to_i    
    name = params[:organisation_name]
    description = params[:description]
    website = params[:website]
    profileImage = params[:profileImage] 

    #if(id != current_user.id)
    #  render json: {"ok"=>false, "data"=>{"errorCode"=>403, "errorMessage"=>"Unauthorized user."}}, status: 403
    #end
    # Check if you current_user is the admin of the org.

    @org = Organization.find(id)
    if(name && name != @org.organization_name)
      @org.organization_name = name
    end
    if(description && description != @org.description)
      @org.description = description
    end
    if(website && website != @org.website)
      @org.website = website
    end
    if(profileImage && profileImage != @org.profile_image)
      @org.profile_image = profileImage
    end  
    @org.save!
  end

  def sanitize_search_results_for_api(result)
    sanitized_response = {}
    sanitized_response["id"] = result["id"]
    sanitized_response["title"] = result["name"]
    sanitized_response["slug"] = result["url_slug"]
    sanitized_response["count"] = 1
    sanitized_response["imageUrls"] = [{"aspectRatio"=> 320.0/240.0,
                                        "cropCoords"=> result["crop_coords"],
                                        "sizes"=>result["image_sizes"]
                                       }]
    sanitized_response
  end

  def set_offline_book_popup_seen
    if (current_user)
      current_user.offline_book_popup_seen = true
      if current_user.save
        render json: {"ok" => true}
      else
        render json: {"ok" => false}, status: 500
      end  
    else
      render json: {"ok" => false}, status: 401
    end
  end

  #PUT /api/v1/user/popup-seen
  def set_popup_seen
    if(current_user)
      user_popup = UserPopup.new
      user_popup.user_id = current_user.id
      user_popup.name = params[:popupType]
      if (current_user.user_popups.find_by_name(params[:popupType]).nil? && user_popup.save!)
        render json: {"ok"=>true}
      else
        render json: {"ok"=>false}, status: 400
      end
    else
      render json: {"ok"=>false, "data" => {"errorCode" => 400, "errorMessage" => "Unable to find user"}}, status: 400
    end
  end

end
