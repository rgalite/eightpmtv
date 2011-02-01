class ShowsController < ApplicationController
  require 'net/http'
  
  before_filter :authenticate_user!, :only => [ :my, :subscribe, :unsubscribe ]
  
  public
  
  def index
    name_alpha
    render :action => :name
  end
  
  def search
    if request.xhr?
      results = { :query => params[:query], :suggestions => [], :data => [] }
      series = Series.where("lower(name) LIKE lower(:name)", { :name => "%#{params[:query]}%"} ).all
      series.each do |serie|
        results[:suggestions] << serie.full_name
        results[:data] << { :id => serie.id, :param => serie.to_param } 
      end
      render :json => results.to_json
    else
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      results = tvdb.search(params[:q])
      db_series = Series.where("lower(name) LIKE lower(:name)", { :name => "%#{params[:q]}%" }).all
      @series = []
      
      
      respond_to do |format|
        format.html do
          results.each do |s|
            unless s["Overview"].blank?
              db_serie = db_series.detect { |ds| ds.series_id == s["seriesid"].to_i }
              if db_serie.nil?
                s["Link"] = add_show_path(s["seriesid"])
                s["Saved"] = false
              else
                s["Link"] = show_path(db_serie)
                s["Saved"] = true
              end
              @series << s
            end
          end
          redirect_to @series.first["Link"] if @series.size == 1 && @series.first["Saved"]
        end #search.html.erb
        format.json do
          results.each do |s|
            unless s["Overview"].blank?
              db_serie = db_series.detect { |ds| ds.series_id == s["seriesid"].to_i }
              s["Link"] = db_serie.nil? ? add_show_path(s["seriesid"], :format => :json) : show_path(db_serie, :format => :json)
              @series << s
            end
          end 
          render :json => @series
        end
      end
    end
  end
  
  def show
    @series = Series.find(params[:id])
    if current_user
      @comment = Comment.new
      @unseen_episodes = @series.episodes.available.unseen_by(current_user)
      @next_episode = @series.next_episode
    end
    
    respond_to do |format|
      format.html do 
        return (render :my_show) if current_user && current_user.watch?(@series)
      end 
      format.json { render :json => @series.as_json }
    end
  end
  
  def add
    series = Series.where(:series_id => params[:id]).first
    if series.nil?
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      s = tvdb.get_series_by_id(params[:id])
      series = Series.new(:name => s.name, :series_id => s.id,
                          :tvdb_id => s.tvdb_id, :description => s.overview,
                          :first_aired => s.first_aired, :network => s.network,
                          :rating => s.rating, :runtime => s.runtime,
                          :status => s.status == "Continuing",
                          :imdb_id => s.imdb_id,
                          :rating_count => s.rating_count,
                          :air_time => s.air_time, :air_day => s.air_day,
                          :seasons_processing => true, :poster_url => s.poster)
      s.genres.each { |genre| series.genres << Genre.find_or_initialize_by_name(genre) }
      if !series.save
        redirect_to root_url, :notice => "Sorry, there was a problem saving the TV show #{series.full_name}. Try again later."
        return
      end
    end
    
    redirect_to show_path(series)
  end
  
  def follow
    @series = Series.find(params[:id])
    if current_user.following?(@series)
      respond_to do |format|
        format.js   # render follow.js.erb
        format.html { redirect_to shows_path(@series), :notice => "You are not following #{@series.full_name}." }
      end
    else
      fw = current_user.follow(@series)
      a = current_user.activities.create!(:actor_path => user_path(current_user),
                                          :actor_img => current_user.photo.url(:thumb),
                                          :subject => fw,
                                          :kind => "follow_serie",
                                          :data => { "serie_path" => show_path(@series),
                                                    "serie_name" => @series.full_name,
                                                    "serie_img" => @series.poster.url(:thumb),
                                                    "serie_desc" => @series.description }.to_json)
      respond_to do |format|
        format.js   # render follow.js.erb
        format.html { redirect_to shows_path(@series), :notice => "You are not following #{@series.full_name} anymore." }
      end
    end
  end
  
  def unfollow
    @series = Series.find(params[:id])
    if current_user.following?(@series)
      current_user.stop_following(@series)
      respond_to do |format|
        format.js   # render unsubscribe.js.erb
        format.html { redirect_to shows_path(@series), :notice => "You are not following #{@series.name} anymore." }
      end
    else
      respond_to do |format|
        format.js   # render unsubscribe.js.erb
        format.html { redirect_to shows_path(@series), :warn => "You are not following #{@series.name}." }
      end
    end
  end
  
  def actors
  end
  
  def comment
    if user_signed_in?
      @series = Series.find(params[:id])
      @comment = @series.comments.build(:content => params[:comment][:content],
                                 :user => current_user) 
      save_comment(@comment)
      a = current_user.activities.create!(:actor_path => user_path(current_user),
                                          :actor_img => current_user.photo.url(:thumb),
                                          :subject => @comment,
                                          :subject_path => show_path(@series, :anchor => "comment-#{@comment.id}"),
                                          :kind => "comment",
                                          :data => { "content" => @comment.content,
                                                    "commented_name" => @comment.commentable.full_name,
                                                    "commented_path" => show_path(@series) }.to_json)
    end
  end
  
  def name
    name_alpha
  end
  
  def get_poster
    @series = Series.find(params[:id])
    respond_to do |format|
      format.js do
        if @series.poster_processing?
          render :nothing => true, :status => 403
        else
          render :partial => "poster", :locals => { :series => @series }
        end
      end
      format.html { redirect_to show_path(@series) } # redirect to show
    end
  end
  
  def popular
  end
  
  def get_seasons
    @series = Series.find(params[:id])
    respond_to do |format|
      format.js do
        if @series.seasons_processing?
          render :nothing => true, :status => 403
        else
          render :partial => "seasons", :locals => { :series => @series.seasons }
        end
      end
      format.html { redirect_to show_path(@series) } # redirect to show
    end
  end
  
  private
  def name_alpha
    if params[:letter].nil?
      @series = Series.where("name LIKE ? OR name LIKE ? OR name LIKE ? OR name LIKE ? OR name LIKE ? \
                              OR name LIKE ? OR name LIKE ? OR name LIKE ? OR name LIKE ? OR name LIKE ?",
                              "0%", "1%", "2%", "3%", "4%", "5%", "6%", "7%", "8%", "9%")
    elsif ('A'..'Z').include?(params[:letter])
      @series = Series.where("name LIKE ?", "#{params[:letter]}%").order("name asc")
    else
      @series = []
    end
  end
end
