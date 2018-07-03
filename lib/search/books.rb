require_relative "search_helper"

module Search
  class Books
    include SearchHelper

    attr_reader :params, :current_user, :user_signed_in

    DEFAULT_CRITERIA = [
        { _score: {order: :desc} },
        { recommended: {order: :desc} },
        { reads: {order: :desc} },
        { likes: {order: :desc} }
      ]

  	def initialize(params, current_user, user_signed_in)
      @params = params
      @current_user = current_user 
      @user_signed_in = user_signed_in
  	end

    def search
      results = search_params.values.flatten.compact.reject(&:empty?).blank? ? editor_recommended_stories : process_search
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
      sanitized_response["storyDownloaded"] = current_user ? (current_user.organization.present? ? (result["story_downloads"].present? ? result["story_downloads"].include?(current_user.id) : false) : false) : false
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
    
    def search_params
      if @params[:search].blank?
        {query: nil, languages: [], categories: [], reading_levels: [], authors: [], bulk_options: [], derivation_type: [], target_languages: []}
      else
        search_params = @params[:search]
        search_params[:languages] = strip_empty_values search_params[:languages]
        search_params[:categories] = strip_empty_values search_params[:categories]
        search_params[:publishers] = strip_empty_values search_params[:publishers]
        search_params[:organizations] = strip_empty_values search_params[:organizations]
        search_params[:reading_levels] = strip_empty_values search_params[:reading_levels]
        #search_params[:bulk_options] = strip_empty_values search_params[:bulk_options]
        search_params[:derivation_type] = strip_empty_values search_params[:derivation_type]
        search_params[:target_languages] = strip_empty_values search_params[:target_languages]
        search_params[:tags] = strip_empty_values search_params[:tags]
        search_params
      end
    end

    def filters(search_params)
      filters = {}
      filters[:language] = search_params[:languages] unless search_params[:languages].nil? || search_params[:languages].empty?
      unless search_params[:target_languages].nil? || search_params[:target_languages].empty?
        filters[:target_language] = {not: search_params[:target_languages]}
        filters[:publisher] = {not: ""}
      end
      filters[:categories] = search_params[:categories] unless search_params[:categories].nil? || search_params[:categories].empty?
      # filters[:publisher] = search_params[:publishers].last == "storyweaver" ? (search_params[:publishers].fill("", -1)) : search_params[:publishers]  unless search_params[:publishers].nil? || search_params[:publishers].empty?
      filters[:organization] = search_params[:organizations].last == "storyweaver" ? (search_params[:organizations].fill("", -1)) : search_params[:organizations]  unless search_params[:organizations].nil? || search_params[:organizations].empty?
      filters[:reading_level] = search_params[:reading_levels] unless search_params[:reading_levels].nil? || search_params[:reading_levels].empty?
      filters[:derivation_type] = (search_params[:derivation_type].length == 1 && search_params[:derivation_type].include?("nil") ?  nil : search_params[:derivation_type].map{|x| x == "nil" ? nil : x}) unless search_params[:derivation_type].nil? || search_params[:derivation_type].empty?
      filters[:recommended_status] = [:recommended, :home, :home_recommended] unless search_params[:recommended] != true || search_params[:recommended].empty?
      filters[:authors] = search_params[:authors] unless search_params[:authors].nil? || search_params[:authors].empty?
      filters[:page_illustration] = search_params[:illustration_id] unless search_params[:illustration_id].nil? || search_params[:illustration_id].empty?
      filters[:youngsters] = {not: nil} if search_params[:child_created]
      filters[:story_downloads] = ({not: @current_user.id} if @current_user) if search_params[:bulk_download].present? #Condition for stories which current user not downloaded
      filters[:status] = [:published]
      filters[:tags_name] = search_params[:tags] unless search_params[:tags].nil? || search_params[:tags].empty?
      # if current user is aslo a reviewer then show uploaded, edit_in_progress status stories.
      if @current_user && search_params[:cache] != "true" && @current_user.reviewer?
        filters[:status] << :uploaded
        filters[:status] << :edit_in_progress
      end
      return filters
    end

    def translate_filters(search_params)
      filters = {}
      filters[:language] = search_params[:languages] unless search_params[:languages].nil? || search_params[:languages].empty?
      filters[:organization] = {not: ""}
      filters[:organization] = search_params[:organizations]  unless search_params[:organizations].nil? || search_params[:organizations].empty?
      unless search_params[:target_languages].nil? || search_params[:target_languages].empty?
        filters[:target_language] = {not: search_params[:target_languages]}
      end
      filters[:categories] = search_params[:categories] unless search_params[:categories].nil? || search_params[:categories].empty?
      filters[:reading_level] = search_params[:reading_levels] unless search_params[:reading_levels].nil? || search_params[:reading_levels].empty?
      filters[:status] = [:published]
      return filters
    end


    def update_query_to_do_word_match_for_synopsis_and_content(query)
      queries = query.body[:query][:dis_max][:queries] rescue []
      queries.reject! do |q|
        (q[:match].keys.first.include?('synopsis') || q[:match].keys.first.include?('content')) && q[:match][q[:match].keys.first][:fuzziness] == 1
      end
    end

    def process_search
      filters = params[:books_for_translation] ? translate_filters(search_params) : filters(search_params)
      order_criteria = Story.count > 0 ? search_params[:sort] || DEFAULT_CRITERIA : []
      query = search_query(filters, order_criteria, offset = nil)
      update_query_to_do_word_match_for_synopsis_and_content(query)
      @results = query
      @results.map { |result| sanitize_search_results_for_api(result) }

      @search_params = search_params
      @filters = filters
      useful_params = search_params.reject{|k,v|v.nil?||v.blank?}
      {
        query: search_params,
        order: order_criteria,
        search_results: @results.map { |result| sanitize_search_results_for_api(result) },
        metadata: metadata(@results)
      }
    end

    def editor_recommended_stories
      filters = filters(search_params)
      order_criteria = Story.count > 0 ? search_params[:sort] || DEFAULT_CRITERIA : []
      query_results = search_query(filters, order_criteria, offset = nil)
      filters[:editor_recommended] = true
      query_results1 = search_query(filters, order_criteria, offset = nil)
      update_query_to_do_word_match_for_synopsis_and_content(query_results1)
      @results = query_results1.results

      # If current page does not have enough editor recommended stories to show, 
      # then add non editor recommended stories to fill up the remaining slots in current page
      if query_results1.total_count.to_i < (query_results.per_page.to_i * query_results.current_page.to_i)
        params[:per_page] = (query_results.per_page.to_i * query_results.current_page.to_i) - query_results1.total_count.to_i
        params[:per_page] = params[:per_page] < Settings.per_page.entity_count ? params[:per_page] : Settings.per_page.entity_count
        offset = (query_results.per_page.to_i * (query_results.current_page.to_i - 1) - query_results1.total_count.to_i) < 0 ?
        0 : (query_results.per_page.to_i * (query_results.current_page.to_i - 1) - query_results1.total_count.to_i)
        filters[:editor_recommended] = false
        query_results2 = search_query(filters, order_criteria, offset)
        update_query_to_do_word_match_for_synopsis_and_content(query_results2)
        @results =  query_results1.results + query_results2.results
      end

      @search_params = search_params
      puts " @search_params"
      puts  @search_params
      @filters = filters
      useful_params = search_params.reject{|k,v|v.nil?||v.blank?}
      {
        query: search_params,
        order: order_criteria,
        search_results: @results.map { |result| sanitize_search_results_for_api(result) },
        metadata: metadata(query_results)
      }


    end

    def search_query(filters, order_criteria, offset = nil)
      random_score = filters[:editor_recommended] == true ? {function_score:{ random_score: { seed: DateTime.now.strftime("%Y%m%d").to_i } }} : nil
      query = Story.search(
        search_params[:query].blank? ? EVERYTHING : search_params[:query],
        offset: offset,
        page: @params[:page],
        per_page: @params[:per_page] || PER_PAGE,
        operator: "or",
        fields:['title^20', 'english_title^18', 'original_story_title^18',
              'publisher^10', 'illustrators^10', 'authors^10', 'language^10',
              'other_credits^5', 'synopsis^5', 'content', 'tags_name^12', 'categories^12'],
        boost_by: {read_rating: {factor: 15}, rating: {factor: 16}},
        boost_where: {is_flagged: [{value: false, factor: 10}, {value: true, factor: 1}]},
        where: filters,
        order: order_criteria,
        query: random_score,
        load: false,
        execute: false)
      query.execute
    end

  end
end
