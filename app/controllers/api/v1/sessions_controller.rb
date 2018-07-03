class Api::V1::SessionsController < Devise::SessionsController
  skip_before_filter :authenticate_user!, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:sign_out, :destroy, :create]
  skip_before_filter :verify_signed_out_user, only: [:sign_out, :destroy]

  respond_to :json
  after_action :set_csrf_headers, only: :create

  protected
  def set_csrf_headers
    if request.xhr?
      response.headers['X-CSRF-Token'] = "#{form_authenticity_token}"
      response.headers['X-CSRF-Param'] = "#{request_forgery_protection_token}"
    end
  end
end
