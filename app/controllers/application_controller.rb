class ApplicationController < ActionController::Base
  include CallRake
  protect_from_forgery
  
  protected
  def save_comment(c)
    if c.save
      a = current_user.activities.create(:actor_path => user_path(current_user),
                                         :actor_img => current_user.photo.url(:thumb),
                                         :subject => c,
                                         :kind => "comment",
                                         :data => { "content" => c.content,
                                                    "path" => show_path(@series, :anchor => "comment-#{c.id}"),
                                                    "commented_name" => c.commentable.full_name,
                                                    "commented_path" => show_path(@series) }.to_json)
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
