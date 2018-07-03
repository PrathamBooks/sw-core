class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    if params[:user_opinion] == "true"
      org = Organization.where(:organization_name => params[:user][:organization_attributes][:organization_name], :country => params[:user][:organization_attributes][:country]).first
      if org.present?
        @user = User.new(sign_up_params)
      else
        @user = User.new(sign_up_organization_params)
      end
    else
      @user = User.new(sign_up_params)
    end
    if @user.save
      if params[:user_opinion] == "true"
        current_user = User.find_by_email(params[:user][:email])
        @user.organization = org if org.present?
        @user.org_registration_date = DateTime.now
        @user.city = params[:user][:organization_attributes][:city]
        @user.save!
        unless org.present?
          org_translation = @user.organization.translations.try(:first)
          org_translation.translated_name = @user.organization.organization_name
          org_translation.save!
        end
        content_managers = User.content_manager.collect(&:email).join(",")
        UserMailer.delay(:queue=>"mailer").organization_user_signup(content_managers,@user.organization,current_user)
      end
      message = "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
      render json: {"ok"=>true, :message => message}, status: 201
    else
      render json: @user.errors.full_messages
    end
  end

  private

  def sign_up_organization_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, organization_attributes:[:organization_name,:organization_type, :country, :city, :number_of_classrooms, :children_impacted])
  end

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :language_preferences)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :language_preferences)
  end
end
