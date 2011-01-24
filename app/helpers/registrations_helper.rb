module RegistrationsHelper
  def tab_active_class(tab_name = nil)
    if params[:tab].blank? && tab_name == "account"
      " class=\"selected\"".html_safe
    else
      params[:tab] == tab_name ? " class=\"selected\"".html_safe : ""
    end
  end
  
  def error_explanation_tag(record, tag, resource_name)
    if record.errors[tag].any?
      errors_list = "<ul>"
      record.errors[tag].each { |e| errors_list << "<li>#{tag.to_s.humanize} #{e}</li>" }
      errors_list << "</ul>"
      res = content_tag(:div, errors_list.html_safe, :style => "display:none", :id => "#{form_tag_id(resource_name, tag.to_s)}_tip")
    end
  end
end
