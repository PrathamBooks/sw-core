class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  before_filter :store_location
  before_action :set_locale, :set_popup

  private

  def fog_directory
    credentials =  YAML.load_file("#{Rails.root}/config/fog.yml")
    connection = Fog::Storage.new(credentials.values.first.symbolize_keys!)
    connection.directories.get(Settings.fog.directory)
  end

  def set_locale
   I18n.locale = session[:locale] || I18n.default_locale
  end

  def set_popup
    session[:phonestories_popup] = false;
  end

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def store_location_and_redirect(store_path = root_path,redirect_path)
    unless current_user
      if request.xhr?
        session[:user_return_to] = store_path
        render :js => "window.location = '#{redirect_path}'"
      else
        session[:user_return_to] = store_path
        redirect_to redirect_path
        response.headers['X-Message'] = flash[:error]  unless flash[:error].blank?
      end
    end
  end

  def get_autocomplete_items(parameters)
    super(parameters).presence || [OpenStruct.new(id: '', parameters[:method].to_s => '')]
  end

  def store_location
  # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get? 
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/confirmation/new" &&
        request.path != "/users/sign_out" &&
        request.path != "/users/auth/google_oauth2/callback" &&
        request.path != "/users/auth/facebook/callback" &&
        !request.path.include?('api') &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath 
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_viewport_sizes, :set_view_popup

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end

  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end
  def set_viewport_sizes
    @viewport_width = cookies['_w']
    @viewport_height = cookies['_h']
  end

  def set_view_popup
    session[:check_user_signed_in] = session[:viewed_popup] = true if user_signed_in?
    unless session[:viewed_popup]
      time_out = 180000
      session[:start_time] ||= Time.now
      remaining_time = time_out - ((Time.now - session[:start_time].to_time) * 1000).to_i
      session[:popup_time] = if remaining_time < 0
                               time_out
                             elsif remaining_time > 0 && remaining_time < 10000
                               10000
                             else
                               remaining_time
                             end

    end
  end
end
