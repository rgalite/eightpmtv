class ShowsController < ApplicationController
  require 'net/http'

  private
  def download_banner(series_banner)
    unless series_banner.nil?
      s3_config = YAML.load_file(File.join(RAILS_ROOT, "config", "amazon_s3.yml"))
      
      AWS::S3::Base.establish_connection!(
        :access_key_id     => s3_config[RAILS_ENV]["access_key_id"],
        :secret_access_key => s3_config[RAILS_ENV]["secret_access_key"]
      )
      
      begin
        banner_url = "http://thetvdb.com/banners/#{series_banner}"
        banner_s3_path = "assets/search/banners/#{series_banner}"
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
        if db_serie.nil?
          s["Link"] = show_path(:id => "#{s["seriesid"]}", :new => true)
          s["banner"] = download_banner(s["banner"])
        else
          s["Link"] = show_path(db_serie)
          s["banner"] = download_banner(s["banner"])
        end
        @series << s
      end
    end
  end
  
  def show
    if params[:new] === "true"
      series = Series.where(:series_id => params[:id]).first
      if !series.nil?
        redirect_to show_path(series)
        return
      end
      
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      s = tvdb.get_series_by_id(params[:id])
      
      series = Series.new(:name => s.name, :series_id => params[:id],
                          :description => s.overview, :first_aired => s.first_aired,
                          :network => s.network, :rating => s.rating,
                          :runtime => s.runtime)
      series.save
      return (redirect_to show_path(series))
    else
      @series = Series.find(params[:id])
    end
  end
end
