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
                                :access => :public_read)
        banner = AWS::S3::S3Object.find(banner_s3_path, "rmgalite-tvshows")
      ensure
        return banner.url
      end                              
    end
  end
  
  public
  
  def index
    if params[:letter] == '0'
      @series = Series.where(:name => "%")
    elsif ('A'..'Z').include?(params[:letter])
      @series = Series.where("name LIKE ?", params[:letter] + '%')
    else
      @series = []
    end
  end
  
  def search
    params[:q]
    tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
    results = tvdb.search(params[:q])
    db_series = Series.where("name LIKE :name", { :name => "%#{params[:q]}%" }).all
    
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
  
  def show
    @series = Series.find(params[:id])
  end
  
  def add
    series = Series.where(:series_id => params[:id]).first
    if series.nil?
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      s = tvdb.get_series_by_id(params[:id])

      series = Series.new(:name => s.name, :series_id => s.id,
                          :tvdb_id => s.tvdb_id,
                          :description => s.overview, :first_aired => s.first_aired,
                          :network => s.network, :rating => s.rating,
                          :runtime => s.runtime, :status => s.status == "Continuing",
                          :imdb_id => s.imdb_id, :language => s.language,
                          :rating_count => s.rating_count,
                          :air_time => s.air_time, :air_day => s.air_day,
                          :banner => s.banner, :poster => s.poster, :fanart => s.fanart)
      
      call_rake "tvdb:download_banners", { :banners => [series.banner, series.fanart].join('|') }
      download_banner(series.poster)
      series.set_actors(s.actors)      
      series.save
    end
    
    redirect_to show_path(series)
  end
end
