class SessionsController < Devise::SessionsController
  respond_to :json

  after_action :set_csrf_headers, :check_locale, only: :create
  skip_before_filter :verify_authenticity_token, :only => [:sign_out, :destroy]

  def check_locale
    if session[:locale]
      current_user.update_attribute(:locale_preferences, session[:locale])
    else
      session[:locale] = current_user.locale_preferences
    end
  end

  protected
    def set_csrf_headers
      if request.xhr?
        response.headers['X-CSRF-Token'] = "#{form_authenticity_token}"
        response.headers['X-CSRF-Param'] = "#{request_forgery_protection_token}"
      end
    end
end
