class RegistrationsController < Devise::RegistrationsController
  def create
    if session[:omniauth] == nil #OmniAuth
      if verify_recaptcha
        super
        session[:omniauth] = nil unless @user.new_record? #OmniAuth
      else
        build_resource
        clean_up_passwords(resource)
        flash[:error] = "There was an error with the recaptcha code below. Please re-enter the code and click submit."
        render_with_scope :new
      end
    else
      super
      session[:omniauth] = nil unless @user.new_record? #OmniAuth
    end
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
end
