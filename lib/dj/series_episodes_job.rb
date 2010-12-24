class SeriesEpisodesJob < Struct.new(:series_id)
  def perform
    p "Loading SeriesEpisodesJob job"
    p "Looking for serie with id #{series_id}"
    serie = Series.find(series_id)
    p "Series found: #{serie.name}"
    p "Loading the TVDB api"
    tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
    p "Looking for serie on the TVDB api"
    s = tvdb.get_series_by_id(serie.tvdb_id)
    episodes = s.episodes
    season_number = -1
    p "#{episodes.size} episodes loaded"
    season = nil
    episodes.each_with_index do |ep, i|
      p "Current season number : #{season_number} -- episode's season's number #{ep.season_number}"
      if !ep.season_number.strip.to_i.zero? && !ep.number.strip.to_i.zero?
        if season_number != ep.season_number
          season_number = ep.season_number
          p "Processing season #{season_number} ..."
          season = Season.find_or_initialize_by_tvdb_id(ep.season_id.to_i,
                    :number => season_number.to_i, :poster_processing => false)
          season.poster_url = s.season_posters(season.number).first.path unless s.season_posters(season.number).first.nil?
          serie.seasons << season
          p "Season #{season.number} added to the serie #{serie.name}"
        end
        p "#{serie.name} episode n.#{i + 1} (#{ep.name}) loaded"
        season.episodes << Episode.new(:tvdb_id => ep.id, :number => ep.number,
                              :name => ep.name, :description => ep.overview,
                              :director => ep.director, :writer => ep.writer,
                              :first_aired => ep.air_date)
        p "#{serie.name} S#{ep.season_number.rjust(2, '0')}E#{ep.number.rjust(2, '0')} - #{ep.name} added"
      end
    end

    serie.seasons_processing = false
    serie.save
  end
end
