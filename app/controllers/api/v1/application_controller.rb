class Api::V1::ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_filter :flash_to_http_header
  before_action :set_i18n_locale

  #POST /api/v1/set-locale
  def set_locale
    if(params[:locale])
      session[:locale] = params[:locale]
      if(current_user)
        current_user.update_attribute(:locale_preferences, params[:locale])
      end
      render json: {"ok"=>true}
    else
      render json: {"ok"=>false, "data" => {"errorCode" => 400, "errorMessage" => "locale paramter missing"}}, status: 400
    end
  end

  def open_popup
    if(current_user)
      session[:phonestories_popup] = true
      phonestories_popup = PhonestoriesPopup.new
      phonestories_popup.user_id = current_user.id
      phonestories_popup.popup_opened = session[:phonestories_popup]
      phonestories_popup.save!
      render json: {"ok"=>true}
    else
      render json: {"ok"=>false, "data" => {"errorCode" => 400, "errorMessage" => "Unable to find current_user"}}, status: 400
    end
  end

  private
  # Display flash messages with react.
  # ref. http://rdnewman.github.io/coding/2014/11/16/reactjs-flash.html
  def flash_to_http_header
    return if flash.empty?
    response_body = JSON.parse(response.body)
    #Added flash message to the body of the response
    response_body["flashMessages"] = flash.to_hash
    response.body = response_body.to_json
    flash.discard  # flash should not appear when you reload or navigate from page
  end

  def set_i18n_locale
   I18n.locale = session[:locale] || I18n.default_locale
  end

  def user_not_authorized
    render json: {"ok"=> false, "data" => {"errorCode" => 401, "errorMessage" => "You are not authorized to perform this action."}}, status: 401
  end

  def resource_not_found
    render json: {"ok"=>false, "data" => {"errorCode"=>404, "errorMessage" => "The URI requested is invalid. Resource requested doesn't exist"}}, status: 404
  end

end
