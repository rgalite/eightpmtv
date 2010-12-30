class AuthenticationsController < ApplicationController
  # GET /authentications
  # GET /authentications.xml
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
    @authentication.destroy
      
    redirect_to(authentications_url)
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
