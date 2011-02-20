class ApplicationController < ActionController::Base
  include CallRake
  protect_from_forgery
  
  helper_method :show_season_episode_path_, :show_season_episode_url_
  def robots
    render :text => open(File.join(Rails.root, "public", "robots.#{Rails.env}.txt")).read, :layout => false
  end
  
  def show_season_episode_path_(episode, options = {})
    if options.keys.include?(:anchor)
      show_season_episode_path(:show_id => episode.series,
                               :season_number => episode.season.number,
                               :episode_number => episode.number, :anchor => options[:anchor])
    else
      show_season_episode_path(:show_id => episode.series,
                               :season_number => episode.season.number,
                               :episode_number => episode.number)
    end
  end
  
  def show_season_episode_url_(episode, options = {})
    if options.keys.include?(:anchor)
      show_season_episode_url(:show_id => episode.series,
                               :season_number => episode.season.number,
                               :episode_number => episode.number, :anchor => options[:anchor])
    else
      show_season_episode_url(:show_id => episode.series,
                               :season_number => episode.season.number,
                               :episode_number => episode.number)
    end
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
