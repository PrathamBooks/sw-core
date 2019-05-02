class BlogPostsController < ApplicationController
  before_action :authorize_action, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_blog_post, only: [:show, :edit, :update, :destroy]
  before_action :blog_list
  respond_to :html
  autocomplete :tag, :name, :class_name => 'ActsAsTaggableOn::Tag'

  EVERYTHING = "*"
  PER_PAGE = 3

  DEFAULT_CRITERIA = [
    { _score: {order: :desc} },
    { updated_at: {order: :desc} }
  ]


  def index
    results = process_search
    @blog_posts = results.execute
    respond_with(@blog_posts)
  end

  def show
    BlogPost.increment!(params[:id], :reads)
    respond_with(@blog_post)
  end

  def new
    @blog_post = BlogPost.new
    respond_with(@blog_post)
  end

  def edit
  end

  def create
    params[:blog_post][:published_at] = Time.now.strftime("%Y-%m-%d %H:%M:%S") if params[:blog_post][:status]=="published"
    @blog_post = BlogPost.new(blog_post_params)
    @blog_post.user = current_user
    if @blog_post.save
      flash[:notice] = "#{@blog_post.title} was successfully created."
    else
      flash[:error] = @blog_post.errors.full_messages.to_sentence
    end
    respond_with(@blog_post)
  end

  def update
    if params[:blog_post][:status]=="published"
      params[:blog_post][:published_at] = Time.now.strftime("%Y-%m-%d %H:%M:%S") unless @blog_post.status == "published"
    end
    params[:blog_post][:user_id] = current_user.id
    if @blog_post.update(blog_post_params)
      flash[:notice] = "#{@blog_post.title} was successfully Updated."
    else
      flash[:error] = @blog_post.errors.full_messages.to_sentence
    end
    respond_with(@blog_post)
  end

  def destroy
    @blog_post.destroy
    flash[:notice] = "#{@blog_post.title} has been deleted successfully."
    redirect_to request.referer
  end

  def blog_list
    @blog_search = true
    conditions = {}
    conditions[:status] = Story.statuses[:published]
    blog_posts = BlogPost.where(conditions)
    @blog_posts_by_tags = {}
    blog_posts_by_tags = blog_posts.map {|b| b.tag_list.map{|t|  @blog_posts_by_tags[t] ||= 0; @blog_posts_by_tags[t] += 1}}
    @blog_posts_by_month = blog_posts.group_by { |t| t.created_at.beginning_of_month }
    @blog_actions_authorization = true if current_user && (current_user.content_manager? || current_user.promotion_manager?)
  end

  def search
    @search_query = search_params[:query]
    results = process_search
    @blog_posts = results.execute
    render :file => 'blog_posts/index'
  end

  def dashboard
    @current_tab = 'published'
    @blog_posts = BlogPost.where(:status => BlogPost.statuses[:published]).order(published_at: :desc)
  end

  def drafts
    @current_tab = 'drafts'
    @blog_drafts = BlogPost.where(:status => BlogPost.statuses[:draft]).order(created_at: :desc)
  end

  def de_activated
    @current_tab = 'de_activated'
    @blog_de_activated = BlogPost.where(:status => BlogPost.statuses[:de_activated]).order(created_at: :desc).page(params[:page]).per(10)
  end

  def new_comments
    @current_tab = 'new_comments'
    @comments = Comment.all.order(created_at: :desc) 
  end

  def scheduled_posts
    @current_tab = 'scheduled'
    @blog_scheduled_posts = BlogPost.where(:status => BlogPost.statuses[:scheduled]).order(created_at: :desc).page(params[:page]).per(10)
  end

  def process_search
    filters = filters()
    order_criteria = BlogPost.count > 0 ? sort_params || DEFAULT_CRITERIA : []
    query = BlogPost.search(
      search_params[:query].blank? ? EVERYTHING : search_params[:query],
      page: params[:page],
      per_page: params[:per_page] || PER_PAGE,
      operator: "or",
      fields:['title^20', 'tags_name^10'],
      where: filters,
      order: order_criteria,
      load: false,
      execute: false)
    return query
  end

  def search_params
    if params[:search].blank?
      {query: nil, tags_name: nil, archive: nil}
    else
      search_params = params.require(:search).permit(
        :query,
        :tag_name,
        :archive,
        sort:[

          {
            updated_at: :order
          }
        ]
      )
      search_params
    end
  end

  def filters
    filters = {}
    filters[:tags_name] = search_params[:tag_name] unless search_params[:tag_name].nil? || search_params[:tag_name].empty?
    filters[:archive] = search_params[:archive] unless search_params[:archive].nil? || search_params[:archive].empty?
    filters[:status] = [:published]
    return filters
  end

  def sort_params
    sort = nil
    if params[:sort]
      sort = [
        {
          language: {order: params[:direction]=='asc' ? :asc : :desc}
        }
      ]
    end
    sort
  end

  def banners
    @current_tab = "banner_upload"
    @banners = Banner.page(params[:page]).per(12)
  end

  def create_banner
    position = params[:banner].delete(:position) 
    @banner = Banner.create(banner_params)
    if @banner.save && @banner.insert_at(position.to_i)
      flash[:notice] = "Banner created successfully, the position has shifted one postion right if you have given existing position"
    else
      flash[:error] = "Banner cannot be created"
    end
    redirect_to banners_path       
  end

  def edit_banner
    @banner = Banner.find(params[:id])
  end

  def update_banner
    position = params[:banner].delete(:position) 
    @banner = Banner.find(params[:id])
    if @banner.update_attributes(banner_params) && @banner.insert_at(position.to_i)
      flash[:notice] = "Banner edited successfully"
    end
    redirect_to banners_path     
  end

  def delete_banner
    @banner = Banner.find(params[:id])
    if @banner.destroy
      flash[:notice] = "Banner deleted successfully"
    end 
    redirect_to banners_path
  end

  private
    def set_blog_post
      @blog_post = BlogPost.find(params[:id])
    end

    def authorize_action
      authorize self, :default
    end

    def blog_post_params
      params.require(:blog_post).permit(:title, :body, :status, :scheduled, :published_at, :comments_count, :user_id, :tag_list, :blog_post_image, :add_to_home, :image_caption)
    end

    def banner_params
      params.require(:banner).permit(:name, :banner_image, :link_path, :is_active)
    end
end
