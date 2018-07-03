require_relative "search_helper"

module Search
  class Lists
    include SearchHelper
    
    attr_reader :params, :current_user, :user_signed_in

    DEFAULT_CRITERIA = [
        { _score: {order: :desc} },
        { views: {order: :desc} },
        { likes: {order: :desc} }
      ]

    def initialize(params, current_user, user_signed_in, session)
      @params = params
      @current_user = current_user 
      @user_signed_in = user_signed_in
      @session = session
    end

    def sanitize_search_results_for_api(result)
      sanitized_response = {}
      sanitized_response["title"] = result["title"]
      sanitized_response["id"] = result["id"]
      sanitized_response["count"] = result["count"]
      sanitized_response["description"] = result["description"]
      sanitized_response["slug"] = result["slug"]
      sanitized_response["categories"] = result["categories"]
      sanitized_response["books"] = result["books"]
      sanitized_response["language"] = result["language"]
      sanitized_response["level"] = result["reading_level"]
      sanitized_response["canDelete"] = result["can_delete"]
      sanitized_response
    end

    def sanitize_search_results_for_api_search(result)
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

    def search_params
      if @params[:search].blank?
        return {query: nil, status: [], languages: [], categories: [], reading_levels: [], author_id: nil, organization_id: nil}
      end
      search_params = @params.require(:search).permit(:query, :cache, :author_id, :organization_id, :min_story_count, status: [], languages: [], categories: [],reading_levels: [], 
                                                      sort:[{views: :order}, {likes: :order},{published_at: :order },
                                                      {created_at: :order}]
                                                    )
      search_params[:languages] = strip_empty_values search_params[:languages]
      search_params[:status] = strip_empty_values search_params[:status]
      search_params[:categories] = strip_empty_values search_params[:categories]
      search_params[:reading_levels] = strip_empty_values search_params[:reading_levels]
      search_params[:author_id] = search_params[:author_id] unless search_params[:author_id].nil? 
      search_params[:organization_id] = search_params[:organization_id] unless search_params[:organization_id].nil?
      search_params
    end

    def filters(search_params)
      filters = {}
      filters[:languages] = search_params[:languages] unless search_params[:languages].nil? || search_params[:languages].empty?
      filters[:categories] = search_params[:categories] unless search_params[:categories].nil? || search_params[:categories].empty?
      filters[:reading_levels] = search_params[:reading_levels] unless search_params[:reading_levels].nil? || search_params[:reading_levels].empty?
      filters[:author_id] = search_params[:author_id] unless search_params[:author_id].nil? 
      filters[:organization_id] = search_params[:organization_id] unless search_params[:organization_id].nil?
      # If looking for author lists, do not return lists which are attached to org as these are already published.
      filters[:organization_id] = nil unless search_params[:author_id].nil?
      filters[:status] = search_params[:status] unless search_params[:status].nil? || search_params[:status].empty?
      min_story_count = search_params[:min_story_count].nil? ? 0 : search_params[:min_story_count]
      filters[:count] = {gte: min_story_count}
      return filters
    end

    def search
      filters = filters(search_params)
      order_criteria = List.count > 0 ? search_params[:sort] || DEFAULT_CRITERIA : []
      query = search_query(filters, order_criteria, offset = nil)
      @results = query
      {
        query: search_params,
        order: order_criteria,
        search_results: @results.map { |result| sanitize_search_results_for_api(result) },
        metadata:
          {
            hits:         @results.total_count,
            perPage:     @results.per_page,
            page:         @results.current_page,
            totalPages:  @results.total_pages
          }
      }
    end

    def general_search
      filters = filters(search_params)
      order_criteria = List.count > 0 ? search_params[:sort] || DEFAULT_CRITERIA : []
      query = search_query(filters, order_criteria, offset = nil)
      @results = query
      {
        query: search_params,
        order: order_criteria,
        search_results: @results.map { |result| sanitize_search_results_for_api_search(result) },
        metadata:
          {
            hits:         @results.total_count,
            totalReads:   @results.response["aggregations"]["reads_count"]["sum"],
            perPage:     @results.per_page,
            page:         @results.current_page,
            totalPages:  @results.total_pages
          }
      }
    end

    def search_query(filters, order_criteria, offset = nil)
      # Different users would like to see different results.
      # Randomize the list results based on user session.
      # No randomization for query search.
      random_score = @session.nil? ? nil : {function_score:{ random_score: { seed: @session.id } }}
      query = List.search(
        search_params[:query].blank? ? EVERYTHING : search_params[:query],
        page: @params[:page],
        per_page: @params[:per_page] || PER_PAGE,
        operator: "or",
        fields:['title^20', 'description^15', 'stories_tips^10', 'languages'],
        body_options: {aggs: {reads_count: {stats: {field: :views}}}},
        where: filters,
        order: order_criteria,
        query: random_score,
        load: false,
        execute: false)
      query.execute
    end
  end
end
