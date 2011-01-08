module RegistrationsHelper
  def tab_active_class(tab_name = nil)
    if params[:tab].blank? && tab_name == "account"
      " class=\"selected\"".html_safe
    else
      params[:tab] == tab_name ? " class=\"selected\"".html_safe : ""
    end
  end
end
