class SeriesActorsJob < Struct.new(:series_id)
  def perform
    series = Series.find(series_id)
    tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
    s = tvdb.get_series_by_id(series.tvdb_id)
  
    unless s.actors.nil?
      series.set_actors(s.actors)
      series.save
    end
  end
end