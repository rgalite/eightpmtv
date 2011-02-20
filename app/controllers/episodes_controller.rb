class EpisodesController < ApplicationController
  before_filter :authenticate_user!, :only => [:comment, :mark, :rate, :unmark]
  def show
    @episode = Episode.find_by_show_id_and_season_number_and_episode_number(params[:show_id],
               params[:season_number], params[:episode_number])
    @page_title = "#{@episode.series.full_name} S#{@episode.season.number.to_s.rjust(2, '0')}E#{@episode.number.to_s.rjust(2, '0')}"
    respond_to do |format|
      format.json { render :json => @episode }
      format.html
    end
  end
  
  def get_poster
    @episode = Episode.find(params[:id])
    respond_to do |format|
      format.js do
        if @episode.poster_processing?
          render :nothing => true, :status => 403
        else
          render :partial => "poster", :locals => { :episode => @episode }
        end
      end
      format.html { redirect_to episode_path(@episode) } # redirect to show
    end
  end
  
  def mark
    episode = Episode.find(params[:id])
    current_user.episodes_seen << episode
    respond_to do |format|
      format.js do
        render :partial => "shows/episode_check.my", :locals => { :episode => episode }
      end
      format.html { redirect_to show_season_episode_path_(episode) }
    end
  end
  
  def unmark
    episode = Episode.find(params[:id])
    current_user.episodes_seen.delete(episode)
    respond_to do |format|
      format.js do
        render :partial => "shows/episode_check.my", :locals => { :episode => episode }
      end
      format.html { redirect_to show_season_episode_path_(episode) }
    end
  end
  
  def comment
    if user_signed_in?
      @episode = Episode.find(params[:id])
      @comment = @episode.comments.build(:content => params[:comment][:content],
                                 :user => current_user)
      series = @episode.series
      season = @episode.season 
      save_comment(@comment)
      unless @comment.new_record?
        a_data = { "content" => @comment.content,
                   "commented_name" => @comment.commentable.full_name,
                   "commented_path" => show_season_episode_path_(@episode) }
        a = current_user.activities.create!(:actor_path => user_path(current_user),
                                            :actor_img => current_user.avatar_url(:thumb),
                                            :subject => @comment,
                                            :subject_path => show_season_episode_path_(@episode, :anchor => "comment-#{@comment.id}"),
                                            :kind => "comment",
                                            :data => a_data.to_json)
      end
    end
  end
  
  def rate
    @episode = Episode.find(params[:id])
    if params[:episode_rate].blank? || params[:episode_rate].to_i.zero?
      @episode.ratings.where(["user_id = ?", current_user.id]).destroy_all
      flash.now[:notice] = "Vote removed"
      respond_to do |format|
        format.js
        format.html { redirect_to episode_path(@episode), :notice => "Your rating has been removed successfully" } # redirect to show
      end
    elsif %w{ 1 2 3 4 5 }.include? params[:episode_rate]
      @episode.ratings.where(["user_id = ?", current_user.id]).destroy_all
      
      rating = @episode.ratings.build(:value => params[:episode_rate], :user => current_user)
      rating.save
      flash.now[:notice] = "Thanks for your vote"
      respond_to do |format|
        format.js
        format.html { redirect_to episode_path(@episode), :notice => "You have rated the episode successfully" } # redirect to show
      end
    end
  end
end
