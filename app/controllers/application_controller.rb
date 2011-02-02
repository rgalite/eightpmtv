class ApplicationController < ActionController::Base
  include CallRake
  protect_from_forgery
  
  helper_method :show_season_episode_path_
  def robots
    render :text => open(File.join(Rails.root, "public", "robots.#{Rails.env}.txt")).read, :layout => false
  end
  
  def show_season_episode_path_(episode, options = {})
    show_season_episode_path(:show_id => episode.series.id,
                             :season_number => episode.season.number,
                             :episode_number => episode.number, :options => options)
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
