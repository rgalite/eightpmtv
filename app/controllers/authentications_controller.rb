class AuthenticationsController < ApplicationController
  # GET /authentications
  # GET /authentications.xml
  before_filter :authenticate_user!, :except => [:create]

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
      flash[:notice] = "Authentication method created successfully"
      redirect_to(edit_user_registration_path(:tab => "social"))
    else
      session[:omniauth] = clean_omniauth(omniauth)
      redirect_to new_user_registration_url, :notice => "Please, the information below."
    end
  end

  # DELETE /authentications/1
  # DELETE /authentications/1.xml
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    if current_user.encrypted_password.blank? && current_user.authentications.size == 1
      flash[:error] = "You cannot delete the last connection because you have not set a password."
      redirect_to(edit_user_registration_url(:tab => "account"))
    else
      @authentication.destroy
      flash[:notice] = "The connection to #{@authentication.provider} has been deleted successfully"
      redirect_to(edit_user_registration_url(:tab => "social"))
    end
  end
  
  private
  def clean_omniauth(omniauth)
    case omniauth["provider"]
    when "facebook"
      omniauth["user_info"]["nickname"] = omniauth["extra"]["user_hash"]["name"]
      omniauth["user_info"]["email"] = omniauth["extra"]["user_hash"]["email"]
      omniauth["user_info"]["image"] = "http://graph.facebook.com/#{omniauth["uid"]}/picture"
    end
    
    omniauth.except('extra')
  end
end
