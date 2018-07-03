class Api::V1::ListsController < Api::V1::ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search, :filters]
  before_action :set_list, only: [:show, :edit, :update, :destroy, :list_like, :list_unlike, :download]
  skip_before_filter :verify_authenticity_token, only: [:list_like, :list_unlike]

  EVERYTHING = "*"
  PER_PAGE = 10
  DEFAULT_CRITERIA = [
    { _score: {order: :desc} },
    { views: {order: :desc} },
    { likes: {order: :desc} }
  ]
  respond_to :json

  #GET /api/v1/lists
  def index
    order_criteria = List.count > 0 ? search_params[:sort] || DEFAULT_CRITERIA : []
    filters = search_filters(search_params)
    query = List.search(
      search_params[:query].blank? ? EVERYTHING : search_params[:query],
      page: params[:page],
      per_page: params[:per_page] || PER_PAGE,
      operator: "or",
      fields:['title^20', 'description^15', "languages", "reading_levels"],
      where: filters,
      order: order_criteria,
      load: false,
      execute: false)

    results = query.execute

    metadata = {
        hits:         results.total_count,
        per_page:     results.per_page,
        page:         results.current_page,
        total_pages:  results.total_pages
      }

    render json: {"ok"=>true, "metadata" => metadata, "data"=> results}
  end

  #GET /api/v1/lists/:id
  def show
    #Saving the lists read in the session to increase the read count only by one 
    #even if the list is opened multiple times in that session.
    if((session[:opened_lists].nil?) || (session[:opened_lists].exclude? @list.id))
      ListView.create!(:list => @list, :user => current_user.present? ? current_user : nil)
      (session[:opened_lists] ||= []) << @list.id
    end
  end

  #POST /api/v1/lists
  def create
    @list = List.new()
    @list.title = params[:title]
    @list.description = params[:description]
    @list.user = current_user
    if(params[:books])
      book_ids = params[:books].map{|b| b.split('-').first.to_i}
      @list.stories << Story.where(id: book_ids)
    end
    if @list.save!
      render "show"
    else
      render json: @list.errors.full_messages.join(", ")
    end
  end

  #PUT /api/v1/lists/:id
  def update
    authorize @list
    if @list.update(list_params)
      @list.stories.each do |s|
        @list.stories.destroy(s)
      end
      if params[:books].present?
        params[:books].each do |book|
          story = Story.find(book["id"].to_i)
          @list.stories << story
          ls = ListsStory.where(:story => story, :list => @list).first
          # TODO: Need to handle "html" field as well
          ls.how_to_use = book["usageInstructions"]["txt"].nil? ? nil : book["usageInstructions"]["txt"]
          ls.save!
        end
      end
      render "show"
    else
      render json: @list.errors.full_messages.join(", ")
    end
  end

  #DELETE /api/v1/lists/:id
  def destroy
    if !@list.can_delete
      render json: "This list cannot be deleted"
      return
    end 
    authorize @list
    if @list.destroy
      render json: "successfully updated list"
    else
      render json: "List could not be deleted"
    end
  end

  #POST /api/v1/lists/:id/like
  def list_like
    if(@list.likes.exclude? current_user)
      @list.likes << current_user
    end
    render template: "api/v1/lists/show.json.jbuilder"
  end
  
  #DELETE /api/v1/lists/:id/like
  def list_unlike
    if(@list.likes.include? current_user)
      @list.likes = @list.likes.to_a - [current_user]
    end
    render template: "api/v1/lists/show.json.jbuilder"
  end

  #POST /api/v1/lists/:id/add_story/:story_id
  def add_story
    list = List.find(params[:id])
    story = Story.find(params[:story_id])
    list_story = ListsStory.new
    list_story.list = list
    list_story.story = story
    list_story.position = list.stories.count+1
    authorize list
    if list_story.save
      story_ids = list.stories.collect(&:id)
      list.reindex
      render json: {"ok"=>true, :data=>{:stories =>story_ids}}
    else
      render json: list_story.errors.full_messages
    end

  end

  #DELETE /api/v1/lists/:id/remove_story/:story_id
  def remove_story
    list = List.find(params[:id])
    story = Story.find(params[:story_id])
    list_story = ListsStory.where(:story => story, :list => list).first
    authorize list
    if list_story
      list_story.remove_from_list
      list.stories.destroy(story)
      story_ids = list.stories.collect(&:id)
      list.reindex
      render json: {"ok"=>true, :data=>{:stories =>story_ids}}
    else
      render json: list_story.errors.full_messages
    end
  end

  #POST /aip/v1/lists/:id/rearrange_story/:story_id?position_id=position
  def rearrange_story
    list = List.find(params[:id])
    story = Story.find(params[:story_id])
    list_story = ListsStory.where(:story => story, :list => list).first
    authorize list
    list_story.set_list_position(params[:position])
    render json: ListsStory.where(:list => list).order(:position).map{|s| {story_id: s.story_id, position: s.position}}
  end

  #GET /api/v1/me/lists
  def my_lists
    list_params = ActionController::Parameters.new({search: {reading_levels: ["all"], author_id: current_user.id}, page: "1", per_page: "1000"})
    lObj = Search::Lists.new(list_params, nil, false, nil)
    user_lists = lObj.search
    @user_lists_meta = user_lists[:metadata]
    @user_lists_results = user_lists[:search_results].map{|l| l["downloadLinks"]=list_download_links(l["id"]); l}
    render json: {"ok"=>true, "meta"=>@user_lists_meta , "data"=>@user_lists_results}
  end

  #GET /api/v1/lists/filters
  def filters
    categories = ListCategory.all.map{|c| {:name => c.translated_name, :queryValue => c.name}}
    category_filter = {:name => "Category", :queryKey => "category", :queryValues => categories}
    sort_options = [{ "name"=> "Most Liked", "queryValue"=> "likes" }, { "name"=> "Most Viewed", "queryValue"=> "views" }, { "name"=> "New Arrivals", "queryValue"=> "published_at" }]
    results = {:filters => [category_filter], :sortOptions => sort_options}
    render json: {"ok"=>true, "data"=> results}
  end

  include BulkDownload # including lib/bulk_download.rb module.
  def download
    story_ids = @list.stories.map(&:id) # find all stories of list
    story_ids = story_ids.join(",") # convert to comma-separated list

    new_params = {
      high_resolution: params[:high_resolution],
      format: params[:d_format],
      stories_to_download: story_ids,
      list_id: params[:id],
      list_name: @list.title
    }
    # bk_download is in lib/bulk_download.rb module.
    bk_download new_params, current_user,request
  end
  private
  def set_list
    @list = List.find(params[:id])
  rescue ActiveRecord::RecordNotFound 
    resource_not_found
  end
  
  def list_params
    params.require(:list).permit(:title, :description,category_ids: [])
  end

  def search_params
    if params[:search].blank?
      {query: nil, languages: [], categories: [], reading_levels: []}
    else
      search_params = params.require(:search).permit(
        :query,
        :cache,
        languages: [],
        categories: [],
        reading_levels: [],
        sort:[
          {
            views: :order
          },
          {
            likes: :order
          },
          {
            published_at: :order
          },
          {
            created_at: :order
          }
        ]
      )
      search_params[:languages] = strip_empty_values search_params[:languages]
      search_params[:categories] = strip_empty_values search_params[:categories]
      search_params[:reading_levels] = strip_empty_values search_params[:reading_levels]
      search_params
    end
  end

  def strip_empty_values(array)
    array.delete_if {|a| a.nil? || a.strip.empty? || a.strip == "all"} if array
  end

  def search_filters(search_params)
    filters = {}
    filters[:languages] = search_params[:languages] unless search_params[:languages].nil? || search_params[:languages].empty?
    filters[:categories] = search_params[:categories] unless search_params[:categories].nil? || search_params[:categories].empty?
    filters[:reading_levels] = search_params[:reading_levels] unless search_params[:reading_levels].nil? || search_params[:reading_levels].empty?
    filters[:status] = [:published]
    filters[:status] << :draft
    return filters
  end

  def list_download_links(list_id)
    download_links=[]
    ["Low resolution pdf", "A4 size (Print ready pdf)", "epub"].each do |type|
      link_hash = {}
      link_hash['type']=type 
      link_hash['href']=get_download_link(list_id.to_i,type)
      download_links << link_hash
    end
    return download_links
  end

  def get_download_link(list_id,type)
    if(type=="epub")
      list_download_url(id: list_id, d_format: :epub)
    else
      is_high_resolution = type == "A4 size (Print ready pdf)" ? true : false
      list_download_url(id: list_id, d_format: :pdf, high_resolution: is_high_resolution)
    end
  end

end
