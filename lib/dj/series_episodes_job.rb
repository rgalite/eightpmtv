class SeriesEpisodesJob < Struct.new(:series_id)
  def perform
    serie = Series.find(series_id)
    tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
    s = tvdb.get_series_by_id(serie.tvdb_id)
    episodes = s.episodes
    season_number = -1
    season = nil
    episodes.each_with_index do |ep, i|
      if !ep.season_number.strip.to_i.zero? && !ep.number.strip.to_i.zero?
        if season_number != ep.season_number
          season_number = ep.season_number
          season = Season.new(:tvdb_id => ep.season_id.to_i,
                    :number => season_number.to_i,
                    :poster_processing => true)
          season.poster_url = s.season_posters(season.number).first.path unless s.season_posters(season.number).first.nil?
          serie.seasons << season
        end
        season.episodes << Episode.new(:tvdb_id => ep.id, :number => ep.number,
                              :name => ep.name, :description => ep.overview,
                              :director => ep.director, :writer => ep.writer,
                              :first_aired => ep.air_date)
      end
    end

    serie.seasons_processing = false
    serie.save
  end
end
