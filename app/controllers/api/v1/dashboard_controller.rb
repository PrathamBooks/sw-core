class Api::V1::DashboardController < Api::V1::ApplicationController

  respond_to :json
  before_action :authenticate_user!
  before_action :authorize_action

  def institutional_users
    institutional_users = InstitutionalUser.all.reorder("created_at DESC").page(params[:page]).per(12)
    render json: institutional_users
  end

  private
  def authorize_action
    authorize self, :default
  end

end
