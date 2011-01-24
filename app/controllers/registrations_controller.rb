class RegistrationsController < Devise::RegistrationsController
  def create
    super
    session[:omniauth] = nil unless @user.new_record? #OmniAuth
  end
  
  def edit
    super
    @user.settings_notification_episode_available = @user.settings.notification_episode_available
  end

  def cancel_omniauth
    session[:omniauth] = nil
    redirect_to new_user_registration_path
  end

  private
  def build_resource(*args)
    super
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
    end
  end
  
  def after_update_path_for(resource)
    edit_user_registration_path(:tab => params[:tab])
  end
end
