class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    @user = User.find_for_omniauth(env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to_new_registration_with_omniauth
    end
  end
  
  def twitter
    # You need to implement the method below in your model
    @user = User.find_for_omniauth(env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.twitter_data"] = env["omniauth.auth"]
      redirect_to_new_registration_with_omniauth
    end
  end
  
  private
  def redirect_to_new_registration_with_omniauth
    session[:omniauth] = clean_omniauth(env["omniauth.auth"])
    redirect_to new_user_registration_url, :notice => "Please, fill in the information below."
  end
end