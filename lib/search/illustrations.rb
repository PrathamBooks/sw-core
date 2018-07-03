require_relative "search_helper"

module Search
  class Illustrations
    include SearchHelper
        
    attr_reader :params, :filters, :results, :random_results, :illustrator_results, :organization_results
    def self.search params={}
      self.new params
    end

    def initialize params
      @params = search_params(params)
      search_filters = @filters = get_filters
      default_order = [{_score: {order: :desc}}, {updated_at: {order: :desc}}]
      order_citeria = Illustration.count > 0 ? @params[:sort] || default_order : []
      random_score = @params[:editor_fav_images]=="false" && @params[:query].blank? ? {function_score:{ random_score: { seed: params[:current_user]} }} : nil
      @results = search_query(params[:page], params[:per_page], random_score, search_filters, order_citeria, offset = nil)
      @random_results = @results.results

      if @params[:editor_fav_images] == "true"
        return @random_results
      end

      if search_filters[:illustrators].nil? && search_filters[:organization].nil? && !search_filters[:child_illustrators].present?
        if params[:current_user] != 0
          search_filters = {illustrators:  params[:illustrator_name]}
          @illustrator_results = search_query(params[:page], params[:per_page], random_score, search_filters, order_citeria, offset = nil)
          @random_results = @illustrator_results.results
          random_score = {function_score:{ random_score: { seed: DateTime.now.strftime("%Y%m%d").to_i }}}
          search_filters = {illustrators: {not:  params[:illustrator_name]}}
          if @illustrator_results.total_count.to_i < (@results.per_page.to_i * @results.current_page.to_i)
            params[:per_page] = get_per_page(params[:per_page], @illustrator_results.total_count.to_i, @results)
            offset = get_offset(@illustrator_results.total_count.to_i, @results)
            search_filters = {organization: {not: ""}}
            @organization_results = search_query(params[:page], params[:per_page], random_score, search_filters, order_citeria, offset)
            @random_results = @illustrator_results.results + @organization_results.results
          end
          total_count =  (@organization_results ? @organization_results.total_count.to_i : 0) + @illustrator_results.total_count.to_i
          if total_count < (@results.per_page.to_i * @results.current_page.to_i)
            params[:per_page] = get_per_page(params[:per_page], total_count, @results)
            offset = get_offset(total_count, @results)
            search_filters = {organization: ""}
            other_results = search_query(params[:page], params[:per_page], random_score, search_filters, order_citeria, offset)
            @random_results = organization_results.results + other_results.results
          end
        else
          search_filters = {organization: {not: ""}}
          random_score = {function_score:{ random_score: { seed: DateTime.now.strftime("%Y%m%d").to_i }}}
          @organization_results = search_query(params[:page], params[:per_page], random_score, search_filters, order_citeria)
          @random_results = @organization_results.results
          if @organization_results.total_count.to_i < (@results.per_page.to_i * @results.current_page.to_i)
            params[:per_page] = get_per_page(params[:per_page], @organization_results.total_count.to_i, @results)
            offset = get_offset(@organization_results.total_count.to_i, @results)
            search_filters = {organization: ""}
            @other_results = search_query(params[:page], params[:per_page], random_score, search_filters, order_citeria, offset)
            @random_results = @organization_results.results + @other_results.results
          end
        end
      end
    end

    def search_query(page, per_page, random_score, search_filters, order_citeria, offset = nil)
      search_filters.merge!(:is_pulled_down => false) unless @params[:content_manager]
      query = Illustration.search(
        @params[:query].blank? ? '*' : @params[:query],
        offset: offset,
        page: page,
        per_page: per_page || PER_PAGE,
        operator: "or",
        order: order_citeria,
        query: random_score.present? ? random_score : nil,
        fields:['name^10', 'illustrators^10', 'tags_name^5', 'attribution_text'],
        boost_by: {is_publisher_image: {value: true, factor: 7}},
        boost_where: {is_flagged: [{value: false, factor: 10}, {value: true, factor: 1}]},
        where: search_filters,
        load: false,
        execute: false
      )
      query.execute
    end

    def get_per_page(per_page, random_results, results)
      per_page = (results.per_page.to_i * results.current_page.to_i) - random_results
      per_page =  per_page <= 12 ? per_page : 12
    end

    def get_offset(random_results, results)
      (results.per_page.to_i * (results.current_page.to_i - 1) - random_results) < 0 ?
                 0 : (results.per_page.to_i * (results.current_page.to_i - 1) - random_results)
    end

    def get_filters
      filters = {}
      filters[:categories] = all_or_individual(@params[:categories]) unless all_or_individual(@params[:categories]).nil? || all_or_individual(@params[:categories]).empty?
      filters[:organization] = @params[:organization].last == "storyweaver" ? (@params[:organization].fill("", -1)) : @params[:organization]  unless @params[:organization].nil? || @params[:organization].empty?
      filters[:styles] = @params[:styles] unless @params[:styles].nil? || @params[:styles].empty?
      filters[:license_type] = @params[:license_types] unless @params[:license_types].nil? || @params[:license_types].empty?
      filters[:illustrator_slugs] = @params[:illustrator_slugs] unless @params[:illustrator_slugs].nil? ||  @params[:illustrator_slugs].empty?
      filters[:illustrators] =  @params[:illustrators] unless  @params[:illustrators].nil? ||  @params[:illustrators].empty?
      filters[:tags_name] = @params[:tags] unless @params[:tags].nil? || @params[:tags].empty?
      unless (@params[:editor_fav_images].nil? ||  @params[:editor_fav_images].empty?)
        if @params[:editor_fav_images] == "true"
          filters[:favorites] =  @params[:favorites_of_story]
        else
          filters[:favorites] =  {not: @params[:favorites_of_story]}
        end
      end
      unless @params[:is_organization_cm]
        filters[:image_mode] =  @params[:image_mode]  unless @params[:image_mode].nil? || @params[:image_mode].empty?
      end
        filters[:child_illustrators] = {not: nil} if @params[:child_created]
      filters
    end

    private

    def all_or_individual(array)
      return [] if array.nil? || array.empty?
      return  (array.all?{ |i| i == "all" }) ? [] : array
    end

    def search_params(params)
      if params.blank? || params[:search].blank?
        {query: nil, categories: [], styles: [],license_types: [], organization: nil, :is_organization_cm => params[:is_organization_cm], :content_manager => params[:content_manager]}
      else
        search_params = params.require(:search).permit(:query, :child_created, :image_mode, tags: [], categories: [], styles: [],license_types: [], organization: [], sort:[ { reads: :order }, { likes: :order }, {created_at: :order}] )
        search_params[:categories] = strip_empty_values(all_or_individual(search_params[:categories]))
        search_params[:styles] = strip_empty_values search_params[:styles]
        search_params[:license_types] = strip_empty_values search_params[:license_types]
        search_params[:illustrator_slugs] = params[:search][:illustrator_slugs]
        search_params[:illustrators] =  params[:search][:illustrators]
        search_params[:organization] = strip_empty_values(search_params[:organization])
        search_params[:image_mode] = params[:search][:image_mode]
        search_params[:editor_fav_images] = params[:editor_fav_images]
        search_params[:favorites_of_story] = params[:favorites_of_story]
        search_params[:is_organization_cm] = params[:is_organization_cm]
        search_params[:content_manager] = params[:content_manager]
        search_params[:tags] = params[:search][:tags]
        search_params
      end
    end
  end


end
