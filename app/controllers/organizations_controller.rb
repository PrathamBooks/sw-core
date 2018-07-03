class OrganizationsController < ApplicationController
  #autocomplete :organization, :organization_name
  before_action :authenticate_user!, :except => [:autocomplete, :validate_org_name_country] 

  def organization_sign_up_model
    @organization = Organization.new
  end

  def organization_sign_up
    @organization = Organization.where(:organization_name => params[:organization][:organization_name], :country => params[:organization][:country]).first
    unless @organization.present?
      @organization = Organization.new(organization_params)
      if @organization.save
        org_translation = @organization.translations.try(:first)
        org_translation.translated_name = @organization.organization_name
        org_translation.save!
        save_org_user(@organization)
      else
        flash.now[:error] = @organization.errors.full_messages.join(", ")
        respond_to do |format|
          format.js{ render "organization_sign_up_model" }
        end
      end
    else
      save_org_user(@organization)
    end
  end

  def save_org_user(organization)
    @user = User.find(current_user)
    @user.update_attributes(:organization_id =>  organization.id, :org_registration_date => DateTime.now, :city => organization.city)
    @user.save
    flash[:notice] = "You are now signed in as an organisational user. You can download multiple books in multiple formats in one click."
    content_managers=User.content_manager.collect(&:email).join(",")
    UserMailer.delay(:queue=>"mailer").organization_user_signup(content_managers,organization,current_user)
    respond_to do |format|
      format.js {render js: "window.location = '#{react_search_path(:bulk_download => true)}'"}
    end
  end

  def assign_org_role
    @user = User.find_by_id(params[:user_id])
    @org = Organization.find_by_id(@user.organization_id)
    if @org.organization_type == nil
      if params[:role] != "publisher"
        update_org_user(@user,params[:role])
        @org.status = "Approved"
        @org.organization_type = "Educator"
        @org.save!
        respond_to do |format|
          format.js{ render js: "window.location = '#{roles_path}';" }
          format.html{ redirect_to roles_path }
        end
      end
    else
      check_org_user(@user,params[:role])
    end
  end

  def update_org_user(user,role)
    user.update_role(role)
    flash[:notice] = "#{user.first_name} is assigned as "+role+" for "+ user.organization.organization_name
  end

  def check_org_user(user,role)
    if user.organization_roles != nil && user.organization_roles.include?(role)
      role = params[:role] == "admin"? "an admin" : "a publisher" 
      flash[:error] = "#{user.first_name} is already "+role+" for "+user.organization.organization_name
      respond_to do |format|
        format.js{ render js: "window.location = '#{roles_path}';" }
        format.html{ redirect_to roles_path }
      end
    else
      if role == "admin"
        update_org_user(user,role)
        respond_to do |format|
          format.js{ render js: "window.location = '#{roles_path}';" }
          format.html{ redirect_to roles_path }
        end
      else
        if user.organization.organization_type != "Publisher"
          render :assign_org_role
        else
          update_org_user(user,role)
          respond_to do |format|
            format.js{ render js: "window.location = '#{roles_path}';" }
            format.html{ redirect_to roles_path }
          end
        end
      end
    end
  end

  def add_org_logo
    @user = User.find_by_id(params[:user][:id])
    @org = Organization.find_by_id(params[:organization][:id])
    if params[:org] && params[:org][:logo].present?
      @org.status = "Approved"
      @org.logo = params[:org][:logo]
      @org.organization_type = "Publisher"
      @org.save!
      update_org_user(@user,"publisher")
      respond_to do |format|
        format.js{ render js: "window.location = '#{roles_path}';" }
      end
    else
      @org.errors[:base] << "Logo can't be blank."
      render :assign_org_role
    end
  end

  def remove_org_role_dialog
    @user = User.find_by_id(params[:user_id])
    @org = @user.organization
    @role = params[:role]
    @site_role = params[:site_role]
  end

  def remove_org_role
    user = User.find_by_id(params[:user_id])
    roles = user.organization_roles.split(",")
    user.organization_roles = remove_roles(roles, params[:role])
    user.save!
    respond_to do |format|
      format.js{ render js: "window.location = '#{roles_path}';" }
    end
    flash[:notice] = user.first_name+" is successfully removed as "+ params[:role] +" for "+ user.organization.organization_name
  end

  def remove_site_role
    user = User.find_by_id(params[:user_id])
    user.update_attributes(:role => User.roles[:user])
    user.save!
    respond_to do |format|
      format.js{ render js: "window.location = '#{roles_path}';" }
    end
    flash[:notice] = user.first_name+" is successfully removed as "+ params[:role]
  end

  def remove_roles(user_roles, remove_role)
    if user_roles.length > 1
      return remove_role == "admin" ? "publisher" : "admin"
    else
      user_roles.delete(params[:role])
      return nil
    end
  end

  def validate_org_name_country
    organization = Organization.where(:organization_name => params[:org_name], :country => params[:country]).first
    render json: {"org_present" => organization.present? ? "true" : "false", "org" => organization}
  end

  def autocomplete
    render json: Organization.search(params[:query], {
                                             fields: ["organization_name^5"],
                                             match: :word_start,
                                             limit: 10,
                                             load: false,
                                             misspellings: {below: 5}
                                           }).map{|u| "#{u.organization_name}"}.uniq
  end

  private  
  def organization_params
    params.require(:organization).permit(:organization_name,:organization_type, :country, :city, :number_of_classrooms, :children_impacted, :status)
  end
end
