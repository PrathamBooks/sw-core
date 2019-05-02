class SearchController < ApplicationController
  EVERYTHING = "*"
  PER_PAGE = 10
  DEFAULT_CRITERIA = [
        { _score: {order: :desc} },
        { recommended: {order: :desc} },
        { reads: {order: :desc} },
        { likes: {order: :desc} }
      ]
  DEFAULT_CRITERIA_BULK = [
        { published_at: {order: :desc} },
        { reads: {order: :desc} },
      ]

  def translate_search
    results = process_translate_search 
    respond_to do |format|
      format.html
      format.json do
        render json: results
      end
    end
  end

  def search
    if params[:contest_id].present?
      @contest = Contest.find(params[:contest_id])
    end
    @menu = "search"
    @bulk_download_page = params[:bulk_download] if params[:bulk_download].present?
    @bulk_download = params[:bulk_download].present? ? "bulk_download" : "reader"
    @search_query = search_params[:query]
    sort_category = search_params[:recommended] == "true" ? "recommended" : search_params[:sort].try(:keys).try(:first) 
    sort_category = current_user ? (current_user.content_manager? ? "content_manager_" + sort_category : "user" + sort_category) : sort_category if sort_category
    @illustration = Illustration.find_by_id(params[:illustration_id]) if params[:illustration_id].present?
    if search_params[:cache] == "true"
      respond_to do |format|
        format.html
        format.json do
          render json: get_cache(sort_category, params[:page])
        end
      end
    else
      if @bulk_download_page #bulk download page
        results = bulk_download_all_stories
      else
        results = search_params.values.flatten.compact.reject(&:empty?).blank? ? editor_recommended_stories : process_search
      end
      respond_to do |format|
        format.html
        format.json do
          render json: results
        end
      end
    end
  end

  private

  def sanitize_search_results_for_api(result)
    sanitized_response = {}
    [
      "id","title","english_title","reading_level","status","language","script",
      "authors", "author_slugs", "categories","synopsis","recommended","image_url","url_slug",
      "organization","publisher_slug", "illustrators", "illustrator_slugs", "reads","likes", "uploading"
    ].each do |key|
      sanitized_response[key] = result[key]
    end
    sanitized_response[:links]=[
      :self => {
        :rel => 'story',
        :uri => "/stories/#{result.url_slug}",
      },
      :read => {
        :story_uri => "/stories/#{result.url_slug}/pages/#{result.cover_page_id}"
      }, 
      :translate => {
        :story_uri => "/stories/#{result.url_slug}/translate"
      },
      :download => {
        high_res_pdf: "/stories/download-story/#{result.url_slug}.pdf?high_resolution=true",
        low_res_pdf: "/stories/download-story/#{result.url_slug}.pdf",
        epub: "/stories/download-story/#{result.url_slug}.epub"
      },
      :draft_download => {
        high_res_pdf: "/stories/#{result.id}/pages/#{result.cover_page_id}.pdf?high_resolution=true",
        low_res_pdf: "/stories/#{result.id}/pages/#{result.cover_page_id}.pdf",  
        epub: "/stories/#{result.id}/pages/#{result.cover_page_id}.epub"
      }
    ]

    sanitized_response[:story_path] = "/stories/#{result.url_slug}"
    sanitized_response[:can_user_like_story] = user_signed_in? && !has_user_liked_story(result)
    sanitized_response[:user_likes_story] = user_signed_in? && has_user_liked_story(result)
    sanitized_response[:is_disabled] = is_active_story(current_user,result) ? '' : 'disabled' 
    sanitized_response[:content_manager] = current_user ? (current_user.content_manager? ? true : false ) : false
    sanitized_response[:published] = (result.status == "published") ? true : false 
    sanitized_response[:derivation_type] = (result.derivation_type == "translated") ? "Translation" : (result.derivation_type == "relevelled" ) ? "Re-level" : ''
    sanitized_response[:recommended_status] = (result.recommended_status == nil || result.recommended_status == "recommended") ? true : false 
    sanitized_response[:recommended_tag] = (result.recommended_status == "recommended") || result.recommended_status == "home_recommended" ? true : false
    sanitized_response[:recommendation] = result.recommendation.present? && result.recommendation != "2015-01-01" ? true : false
    sanitized_response[:created_by_child] = result.youngsters.present? ? true : false
    sanitized_response[:is_winner] = result.winner ? true : false
    sanitized_response[:story_title] = result.title.gsub(/^(.{30,}?).*$/m,'\1...')
    sanitized_response[:story_url] = "/stories/"+result.url_slug.split("-")[0]
    sanitized_response[:story_category] = result.youngsters.present? ? "Children's entries" : "Adult entries"
    sanitized_response[:contest_name] = result.contest ? result.contest_name : nil
    sanitized_response[:reviewer_comment] = result.reviewer_comment ? true : false
    sanitized_response[:rating_value] = result.reviewer_comment ? result.ratings : nil
    sanitized_response[:published_at] = result.published_at.present? ? result.published_at.to_date.strftime("%d %B, %Y") : ""
    #bulk upload page
    sanitized_response[:story_downloads] = current_user ? (current_user.organization.present? ? (result.story_downloads.present? ? result.story_downloads.include?(current_user.id) : false) : false) : false
    sanitized_response[:organization_status] = current_user ? (current_user.organization.present? ? (@bulk_download_page ? true: false) : false) : false
    sanitized_response[:story_download_count] = current_user ? (current_user.story_downloads.count > 20 ? true : false) : false
    sanitized_response
  end

  def is_active_story(user,story)
    if user
      if story.status == "draft" || story.status == "edit_in_progress" 
        return story.authors.include?(user.name)
      elsif story.status == "uploaded"
        return user.reviewer? || story.authors.include?(user.name)
      elsif story.status == "published"
        return true
      else
        return false
      end
    else
      if story.status == "published"
        return true
      else
        return false
      end
    end
  end

  def has_user_liked_story(story)
    story.liked_users.include?(current_user.id)
  end
  
  def search_params
    if params[:search].blank?
      {query: nil, languages: [], categories: [], reading_levels: [], authors: [], bulk_options: [], derivation_type: [], target_languages: []}
    else
      search_params = params.require(:search).permit(
        :query,
        :recommended,
        :child_created,
        :cache,
        :authors,
        :illustration_id,
        languages: [],
        categories: [],
        organizations: [],
        reading_levels: [],
        derivation_type: [],
        bulk_options: [],
        target_languages: [],
        sort:[
          {
            reads: :order
          },
          {
            likes: :order
          },
          {
            published_at: :order
          },
          {
            recommendation: :order
          },
          {
            ratings: :order
          },
          {
            created_at: :order
          }
        ]
      )
      search_params[:languages] = strip_empty_values search_params[:languages]
      search_params[:categories] = strip_empty_values search_params[:categories]
      search_params[:organizations] = strip_empty_values search_params[:organizations]
      search_params[:reading_levels] = strip_empty_values search_params[:reading_levels]
      search_params[:bulk_options] = strip_empty_values search_params[:bulk_options]
      search_params[:derivation_type] = strip_empty_values search_params[:derivation_type]
      search_params[:target_languages] = strip_empty_values search_params[:target_languages]
      #search_params[:authors] = strip_empty_values search_params[:authors]
      search_params
    end
  end

  def strip_empty_values(array)
    array.delete_if {|a| a.nil? || a.strip.empty? || a.strip == "all"} if array
  end

  def filters(search_params)
    filters = {}
    filters[:language] = search_params[:languages] unless search_params[:languages].nil? || search_params[:languages].empty?
    unless search_params[:target_languages].nil? || search_params[:target_languages].empty?
      filters[:target_language] = {not: search_params[:target_languages]}
      filters[:organization] = {not: ""}
    end
    filters[:categories] = search_params[:categories] unless search_params[:categories].nil? || search_params[:categories].empty?
    filters[:organization] = search_params[:organizations].last == "storyweaver" ? (search_params[:organizations].fill("", -1)) : search_params[:organizations]  unless search_params[:organizations].nil? || search_params[:organizations].empty?
    filters[:reading_level] = search_params[:reading_levels] unless search_params[:reading_levels].nil? || search_params[:reading_levels].empty?
    filters[:derivation_type] = (search_params[:derivation_type].length == 1 && search_params[:derivation_type].include?("nil") ?  nil : search_params[:derivation_type].map{|x| x == "nil" ? nil : x}) unless search_params[:derivation_type].nil? || search_params[:derivation_type].empty?
    filters[:recommended_status] = [:recommended, :home, :home_recommended] unless search_params[:recommended] != true || search_params[:recommended].empty?
    filters[:authors] = search_params[:authors] unless search_params[:authors].nil? || search_params[:authors].empty?
    filters[:page_illustration] = search_params[:illustration_id] unless search_params[:illustration_id].nil? || search_params[:illustration_id].empty?
    filters[:youngsters] = {not: nil} if search_params[:child_created]
    filters[:story_downloads] = ({not: current_user.id} if current_user) unless search_params[:bulk_options].nil? || search_params[:bulk_options].empty?#Condition for stories which current user not downloaded
    filters[:status] = [:published]
    if current_user && search_params[:cache] != "true" && current_user.reviewer?
      filters[:status] << :uploaded
      filters[:status] << :edit_in_progress
    end
    return filters
  end

  def update_query_to_do_word_match_for_synopsis_and_content(query)
    queries = query.body[:query][:dis_max][:queries] rescue []
    queries.reject! do |q|
      (q[:match].keys.first.include?('synopsis') || q[:match].keys.first.include?('content')) && q[:match][q[:match].keys.first][:fuzziness] == 1
    end
  end

  def process_translate_search
    filters = translate_filters(search_params)
    random_score = {function_score:{ random_score: { seed: session.id} }}
    query = Story.search(EVERYTHING,
                         offset: nil,
                         page: params[:page],
                         per_page: params[:per_page] || PER_PAGE,
                         where: filters,
                         query: random_score,
                         load: false,
                         execute: false)
    @results = query.execute

    @filters = filters
    useful_params = search_params.reject{|k,v|v.nil?||v.blank?}
    {
      query: search_params,
      search_results: @results.map { |result| sanitize_search_results_for_api(result) },
      metadata:
      {
        hits:         @results.total_count,
        per_page:     @results.per_page,
        page:         @results.current_page,
        total_pages:  @results.total_pages
      },
      links:
      {
        self: url_for(:action => 'search', :only_path=> true, :search => useful_params, :page => @results.current_page),
        next_page: @results.last_page? ? nil : url_for(:action => 'search', :only_path=> true, :search => useful_params, :page => @results.next_page),
        prev_page: @results.first_page? ? nil : url_for(:action => 'search', :only_path=> true, :search => useful_params, :page => @results.previous_page),
      }
    }
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


  def process_search
    filters = filters(search_params)
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
      metadata:
      {
        hits:         @results.total_count,
        per_page:     @results.per_page,
        page:         @results.current_page,
        total_pages:  @results.total_pages
      },
      links:
      {
        self: url_for(:action => 'search', :only_path=> true, :search => useful_params, :page => @results.current_page),
        next_page: @results.last_page? ? nil : url_for(:action => 'search', :only_path=> true, :search => useful_params, :page => @results.next_page),
        prev_page: @results.first_page? ? nil : url_for(:action => 'search', :only_path=> true, :search => useful_params, :page => @results.previous_page),
      }
    }
  end

  def bulk_download_all_stories
    filters = filters(search_params)
    order_criteria = []
    if search_params[:query].blank?
      order_criteria = Story.count > 0 ? search_params[:sort] || DEFAULT_CRITERIA_BULK : []
    end
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
      metadata:
      {
        hits:         @results.total_count,
        per_page:     @results.per_page,
        page:         @results.current_page,
        total_pages:  @results.total_pages
      },
      links:
      {
        self: url_for(:action => 'search', :only_path=> true, :search => useful_params, :page => @results.current_page),
        next_page: @results.last_page? ? nil : url_for(:action => 'search', :only_path=> true, :search => useful_params, :page => @results.next_page),
        prev_page: @results.first_page? ? nil : url_for(:action => 'search', :only_path=> true, :search => useful_params, :page => @results.previous_page),
      }
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

    # If current page dose not have enough editor recommended stories to show  then add and continue with non editor recommended stories
    if query_results1.total_count.to_i < (query_results.per_page.to_i * query_results.current_page.to_i)
      params[:per_page] = (query_results.per_page.to_i * query_results.current_page.to_i) - query_results1.total_count.to_i
      params[:per_page] = params[:per_page] <= 10 ? params[:per_page] : 9
      offset = (query_results.per_page.to_i * (query_results.current_page.to_i - 1) - query_results1.total_count.to_i) < 0 ?
        0 : (query_results.per_page.to_i * (query_results.current_page.to_i - 1) - query_results1.total_count.to_i)
      filters[:editor_recommended] = false
      query_results2 = search_query(filters, order_criteria, offset)
      update_query_to_do_word_match_for_synopsis_and_content(query_results2)
      @results =  query_results1.results + query_results2.results
    end

    @results.map { |result| sanitize_search_results_for_api(result) }

    @search_params = search_params
    puts " @search_params"
    puts  @search_params
    @filters = filters
    useful_params = search_params.reject{|k,v|v.nil?||v.blank?}
    {
      query: search_params,
      order: order_criteria,
      search_results: @results.map { |result| sanitize_search_results_for_api(result) },
      metadata: 
      {
        hits:         query_results.total_count,
        per_page:     query_results.per_page,
        page:         query_results.current_page,
        total_pages:  query_results.total_pages
      },
      links: 
      {
        self: url_for(:action => 'search', :only_path=> true, :search => useful_params, :page => query_results.current_page),
        next_page: query_results.last_page? ? nil : url_for(:action => 'search', :only_path=> true, :search => useful_params, :page => query_results.next_page),
        prev_page: query_results.first_page? ? nil : url_for(:action => 'search', :only_path=> true, :search => useful_params, :page => query_results.previous_page),
      }
    }

  end


  def search_query(filters, order_criteria, offset = nil)
    random_score = filters[:editor_recommended] == true ? {function_score:{ random_score: { seed: DateTime.now.strftime("%Y%m%d").to_i } }} : nil
    query = Story.search(
      search_params[:query].blank? ? EVERYTHING : search_params[:query],
      offset: offset,
      page: params[:page],
      per_page: params[:per_page] || PER_PAGE,
      operator: "or",
      fields:['original_story_title^20', 'title^15', 'english_title^15', 'tags_name^15',
              'organization^10', 'illustrators^10', 'authors^10', 'language^10',
              'other_credits^5', 'synopsis^5', 'content', 'categories'],
              where: filters,
              order: order_criteria,
              query: random_score,
              load: false,
              execute: false)
    query.execute
  end

  def update_cache(key,page)
    results = process_search
    cache_key = "#{key}_#{page}"
    Rails.cache.write(cache_key, results, :expires_in => 5.minutes)
    read_cache(key,page)
  end

  def read_cache(key,page)
    cache_key = "#{key}_#{page}"
    Rails.cache.fetch(cache_key)
  end

  def get_cache(key,page)
    read_cache(key,page) || update_cache(key,page)
  end

end
