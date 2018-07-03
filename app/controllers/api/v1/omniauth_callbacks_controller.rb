class Api::V1::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def create
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in(@user)
      render :status => 200, :json => { :user => { :email => @user.email, :name => @user.name } }
    else
      render :status => 401, :json => { :errors => "Access denied" }
    end
  end
end