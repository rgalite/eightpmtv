class ShowsController < ApplicationController
  require 'net/http'
  
  private
  def download_banner(series_banner)
    unless series_banner.nil?    
      begin
        banner_url = "http://thetvdb.com/banners/#{series_banner}"
        banner_s3_path = "assets/#{series_banner}"
        banner = AWS::S3::S3Object.find(banner_s3_path, "rmgalite-tvshows")
      rescue
        AWS::S3::S3Object.store(banner_s3_path, open(banner_url), 'rmgalite-tvshows',
                                :access => :private)
        banner = AWS::S3::S3Object.find(banner_s3_path, "rmgalite-tvshows")
      ensure
        return banner.url
      end                              
    end
  end
  
  public
  
  def index
    if params[:letter] == "0"
      @series = Series.where("name LIKE ? OR name LIKE ? OR name LIKE ? OR name LIKE ? OR name LIKE ? \
                              OR name LIKE ? OR name LIKE ? OR name LIKE ? OR name LIKE ? OR name LIKE ?",
                              "0%", "1%", "2%", "3%", "4%", "5%", "6%", "7%", "8%", "9%")
    elsif ('A'..'Z').include?(params[:letter])
      @series = Series.where("name LIKE ? OR name LIKE ?", params[:letter] + '%', "The #{params[:letter]}%").order("name asc")
    else
      @series = []
    end
  end
  
  def search
    if request.xhr?
      results = { :query => params[:query], :suggestions => [], :data => [] }
      series = Series.where("lower(name) LIKE lower(:name)", { :name => "%#{params[:query]}%"} ).all
      series.each do |serie|
        results[:suggestions] << serie.name
        results[:data] << { :id => serie.id, :param => serie.to_param } 
      end
      render :json => results.to_json
    else
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      results = tvdb.search(params[:q])
      db_series = Series.where("lower(name) LIKE lower(:name)", { :name => "%#{params[:q]}%" }).all
    
      @series = []
      results.each do |s|
        unless s["Overview"].blank?
          db_serie = db_series.detect { |ds| ds.series_id == s["seriesid"].to_i }
          s["Link"] = db_serie.nil? ? add_show_path(s["seriesid"]) : show_path(db_serie)
          s["banner"] = download_banner(s["banner"])
          @series << s
        end
      end
    end
  end
  
  def show
    @series = Series.find(params[:id])
    @subscription = nil
    if current_user
      @subscription = Subscription.find_by_user_id_and_series_id(current_user.id, @series.id)
    end
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subscription }
      format.json { render :json => @series }
    end
  end
  
  def add
    series = Series.where(:series_id => params[:id]).first
    if series.nil?
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      s = tvdb.get_series_by_id(params[:id])

      series = Series.new(:name => s.name,
                          :series_id => s.id,
                          :tvdb_id => s.tvdb_id,
                          :description => s.overview,
                          :first_aired => s.first_aired,
                          :network => s.network,
                          :rating => s.rating,
                          :runtime => s.runtime,
                          :status => s.status == "Continuing",
                          :imdb_id => s.imdb_id,
                          :rating_count => s.rating_count,
                          :air_time => s.air_time,
                          :air_day => s.air_day,
                          :poster_url => s.poster,
                          :banner => s.banner,
                          :fanart => s.fanart)

      series.set_actors(s.actors)      
      unless series.save
        redirect_to root_url, :notice => "Sorry, there was a problem saving the serie #{series.name}. Try again later."
        return
      end
    end
    
    redirect_to show_path(series)
  end
  
  def subscribe
    series = Series.find(params[:id])
    @subscription = Subscription.find_by_series_id_and_user_id(series.id, current_user.id)
    @subscription ||= current_user.subscriptions.create(:series => series, :user => current_user)
    
    respond_to do |format|
      format.js   # render subscribe.js.erb
      format.html { redirect_to subscription_path(@subscription) }
      format.xml  { render :xml => @subscription }
    end
  end
  
  def unsubscribe
    @series = Series.find(params[:id])
    @subscription = Subscription.find_by_series_id_and_user_id(@series.id, current_user.id)
    @subscription.destroy unless @subscription.nil?
    
    respond_to do |format|
      format.js   # render unsubscribe.js.erb
      format.html { redirect_to subscriptions_path }
      format.xml  { render :xml => @subscription }
    end
  end
end
