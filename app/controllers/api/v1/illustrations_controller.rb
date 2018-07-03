class Api::V1::IllustrationsController < Api::V1::ApplicationController
  before_action :authenticate_user!, only: [:create, :illustration_like, :illustration_unlike, :flag_illustration]
  respond_to :json

  #GET /illustrations/autocomplete_user_email
  def autocomplete_user_email
    @users = User.where("email ILIKE ?", "%#{params[:term]}%").order!(email: :asc).limit(10).select(:id, :email, :bio, :first_name, :last_name ) if params[:term].present?
    render json: {"ok"=>true, :data => @users || []}, status: 201
  end

  #GET /illustrations/autocomplete_tag_name
  def autocomplete_tag_name
    @tags = ActsAsTaggableOn::Tag.where("name ILIKE ?", "%#{params[:term]}%").limit(10) if params[:term].present?
    render json: {"ok"=>true, :data => @tags || []}, status: 201
  end


  #POST /api/v1/illustration
  def create
    illus_params = illustration_params
    @illustration = Illustration.new(illus_params)
    illus_params.merge!(:illustrators_attributes => params[:illustrators_attributes])
    if current_user && @illustration.set_illustrator(illus_params, current_user)
      @illustration.set_copyright(illus_params, current_user)
      @illustration.reindex
      content_managers=User.content_manager.collect(&:email).join(",")
      UserMailer.delay(:queue=>"mailer").uploaded_illustration(content_managers,@illustration) unless @illustration.organization.present?
      render json: {"ok"=>true, :id => @illustration.id}, status: 201
    else
      render json: {"ok"=> false, "data" => {"errorCode" => 422, "errorMessage" => @illustration.errors.full_messages}}, status: 422
    end
  end

  #GET /api/v1/illustration-fields
  def illustration_fields
    styles = IllustrationStyle.all.map{|is| {:name => is.translated_name, :queryValue => is.name, id: is.id}}
    categories = IllustrationCategory.all.map{|ic| {:name => ic.translated_name, :queryValue => ic.name, id: ic.id}}
    publishers = Organization.where(organization_type: "Publisher").joins(:illustrations)
                                  .uniq.map{|o| {:name => o.translated_name, :queryValue => o.id}}
    publishers.insert(0,{:name => "", :queryValue => ""})
    copyright_years = (1940..Time.now.year).to_a.reverse
    copyright_years = copyright_years.map{|y| {:name => y, :queryValue => y}}
    copyright_years.insert(0,{:name => "", :queryValue => ""})
    copyright_holders = ["Organization", "Illustrator"]
    copyright_holders = copyright_holders.map{|h| {:name => h, :queryValue => h}}
    copyright_holders.insert(0,{:name => "", :queryValue => ""})
    style_filter = {:name => "Style", :queryKey => "style", :queryValues => styles}
    category_filter = {:name => "Category", :queryKey => "category", :queryValues => categories}
    publisher_filter = {:name => "Publisher", :queryKey => "publisher", :queryValues => publishers}
    year_filter = {:name => "Copyright year", :queryKey => "copy_right_year", :queryValues => copyright_years}
    holder_filter = {:name => "CopyRight holder", :queryKey => "copy_right_holder_id", :queryValues => copyright_holders}
    results = {:style => style_filter, :category => category_filter, :publisher => publisher_filter,
                 :copyrightYear => year_filter, :copyrightHolder => holder_filter}
    render json: {"ok"=>true, "data"=> results}
  end

  def show
     @illustration = Illustration.find(params[:id])
     @categories = @illustration.categories.collect{|i| i.name}
     @styles = @illustration.styles.collect{|s| s.name}
     @illustrators = @illustration.illustrators.collect{|i| i.user}
     @similar_illustrations = @illustration.similar(fields: [:illustrators , :categories], where: {illustrators: @illustration.illustrators.map(&:name), categories: @illustration.categories.map(&:name)}, limit: 12, order: {_score: :desc}, operator: "and", load: false).results if @illustration rescue []
     @illustration.increment!(:reads, by = 1)
     image_view_permissions
  rescue ActiveRecord::RecordNotFound 
    resource_not_found
  end

  def restrict_illustration_access
    render json: {"ok"=> true, "data" => {"illustrationAccess" => false}}, status: 200
  end

  def respond_to_show
    render "show"
  end

  #GET /api/v1/illustrations/filters
  def filters
    styles = IllustrationStyle.all.map{|is| {:name => is.translated_name, :queryValue => is.name, id: is.id}}
    categories = IllustrationCategory.all.map{|ic| {:name => ic.translated_name, :queryValue => ic.name, id: ic.id}}
    publishers = Organization.where(organization_type: "Publisher").joins(:illustrations)
  	                          .uniq.map{|o| {:name => o.translated_name, :queryValue => o.organization_name}}
    style_filter = {:name => "Style", :queryKey => "style", :queryValues => styles}
    category_filter = {:name => "Category", :queryKey => "category", :queryValues => categories}
    publisher_filter = {:name => "Publisher", :queryKey => "publisher", :queryValues => publishers}
    results = {:style => style_filter, :category => category_filter, :publisher => publisher_filter}
    sort_options = [{ "name"=> "Most Liked", "queryValue"=> "likes" }, { "name"=> "Most Viewed", "queryValue"=> "views" }, { "name"=> "New Arrivals", "queryValue"=> "published_at" }]
    render json: {"ok"=>true, "data"=> results, :sortOptions => sort_options}
  end

  #POST illustrations/:id/like
  def illustration_like
    illustration = Illustration.find(params[:id])
    if(!(current_user.voted_for? illustration))
      illustration.liked_by current_user
      illustration.reindex
    end
    render json: {"ok"=>true}
  rescue ActiveRecord::RecordNotFound 
    resource_not_found   
  end

  #DELETE illustrations/:id/like
  def illustration_unlike
    illustration = Illustration.find(params[:id])
    if(current_user.voted_for? illustration)
      illustration.unliked_by current_user
      illustration.reindex
    end 
    render json: {"ok"=>true}
  rescue ActiveRecord::RecordNotFound 
    resource_not_found 
  end
  
  #POST illustrations/:id/flag
  def flag_illustration
    illustration = Illustration.find(params[:id])
    if current_user.flagged?(illustration)
      render json: {"ok"=> false, "data" => {"errorCode" => 422, "errorMessage" => "User had already flagged this Illustration."}}, status: 422
    elsif is_reason_empty
      render json: {"ok"=> false, "data" => {"errorCode" => 400, "errorMessage" => "Reason cannot be empty"}}, status: 400
    else
      params[:reasons].delete_if {|x| x=="other"}
      reasons = params[:reasons].join(", ")
      if(params[:otherReason])
        reasons << ", "+params[:otherReason]
      end
      current_user.flag(illustration, reasons)
      illustration.reindex
      content_managers=User.content_manager.collect(&:email).join(",")
      UserMailer.delay(:queue=>"mailer").flagged_illustration(content_managers,illustration,current_user,reasons)
      render json: {"ok"=> true}, status: 200
    end
  rescue ActiveRecord::RecordNotFound 
    resource_not_found  
  end

  def is_reason_empty
    (params[:reasons].nil? || params[:reasons].empty?) || 
    (params[:reasons].delete_if {|x| x=="other"}.empty? &&
      (params[:otherReason].nil? || params[:otherReason].strip==""))
  end

  private

  def image_view_permissions
    if(user_signed_in?)
      policy(@illustration).view? ? respond_to_show : restrict_illustration_access
    elsif (@illustration.is_pulled_down? || @illustration.image_mode)
      authenticate_user!
    else
      respond_to_show
    end
  end

  def illustration_params
    params.permit(
      :name,
      :image,
      :selected_style,
      :tag_list,
      :license_type,
      :copy_right_year,
      :attribution_text,
      :image_mode,
      :organization_id,
      :copy_right_holder_id,
      category_ids: [],
      style_ids: [],
      child_illustrators_attributes:[:id, :name, :age, :_destroy]
      )
  end
end
