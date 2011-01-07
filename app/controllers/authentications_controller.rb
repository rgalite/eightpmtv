class AuthenticationsController < ApplicationController
  # GET /authentications
  # GET /authentications.xml
  before_filter :authenticate_user!, :except => [:create]
  
  def index
    @authentications = current_user.authentications if current_user
  end

  # POST /authentications
  # POST /authentications.xml
  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth["provider"], omniauth["uid"])
    if authentication
      flash[:notice] = "Signed in successfully"
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      current_user.authentications.create!(:provider => omniauth["provider"], :uid => omniauth["uid"])
      flash[:notice] = "Authentication successful"
      redirect_to authentications_url
    else
      session[:omniauth] = clean_omniauth(omniauth)
      redirect_to new_user_registration_url, :notice => "Please, confirm this information."
    end
  end

  # DELETE /authentications/1
  # DELETE /authentications/1.xml
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    if current_user.password.blank? && current_user.authentications.size == 1
      flash[:error] = "You cannot delete the last connection because you have not set a password."
      redirect_to(edit_user_registration_url(:tab => "password"))
    else
      @authentication.destroy
      flash[:notice] = "The connection to #{@authentication.provider} has been deleted successfully"
      redirect_to(edit_user_registration_url(:tab => "connections"))
    end
  end
  
  private
  def clean_omniauth(omniauth)
    case omniauth["provider"]
    when "facebook"
      omniauth["user_info"]["email"] = omniauth["extra"]["user_hash"]["email"]
    end
    
    omniauth.except('extra')
  end
end
