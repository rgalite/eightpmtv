class ApplicationController < ActionController::Base
  include CallRake
  protect_from_forgery
  
  def robots
    render :text => open(File.join(Rails.root, "public", "robots.#{Rails.env}.txt")).read, :layout => false
  end
  
  protected
  def save_comment(c)
    if c.save
      respond_to do |format|
        format.js { render "shared/comment" }
        format.html { redirect_to show_path(@series, :anchor => "comment-#{c.id}") }
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
