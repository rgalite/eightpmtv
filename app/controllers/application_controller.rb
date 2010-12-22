class ApplicationController < ActionController::Base
  include CallRake
  protect_from_forgery
  
  protected
  def save_comment(c)
    if c.save
      respond_to do |format|
        format.js do
          render :partial => "shared/comment", :locals => { :comment => c }
        end
      end
    else
      respond_to do |format|
        format.js do
          render_text = "<p>"
          c.errors.full_messages.each { |m| render_text << m + "<br />" }
          render_text << "</p>"
          
          render :text => render_text, :status => 403
        end
      end
    end
  end
end
