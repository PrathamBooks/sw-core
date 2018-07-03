class RegistrationsController < Devise::RegistrationsController  
    respond_to :json
 
  def new
    @user = User.new
    @user.build_organization
  end

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
        #@user.city = params[:user][:organization_attributes][:city]
        @user.save!
        content_managers = User.content_manager.collect(&:email).join(",")
        UserMailer.delay(:queue=>"mailer").organization_user_signup(content_managers,@user.organization,current_user)
      end
       flash[:notice] = "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
      redirect_to root_path
    else
      @org= params[:user][:organization_attributes]
      @org_data = org
      @organization_error = true if params[:user_opinion] == "true"
      @user.build_organization
      render :action=>'new'
    end
  end

  private
 
  def sign_up_organization_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :city, organization_attributes:[:organization_name,:city, :country, :number_of_classrooms, :children_impacted, :status])
  end
  
  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
  end
end  