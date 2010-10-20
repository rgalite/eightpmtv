class ShowsController < ApplicationController
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
    @series = []
    series_ids = []
    results.each do |s|
      series_ids << s["seriesid"]
      @series << tvdb.get_series_by_id(s["seriesid"])
    end
    call_rake "tvdb:add_series series_list=#{series_ids.join(',')}"
    render :index
  end
  
  def show
    @series = Series.find(params[:id])
  end
end
