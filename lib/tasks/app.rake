namespace :app do
  desc "Look for updates and update the current database"
  task :update_database_with_tvdb => :environment do |t, args|
    tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
    a_time = ApplicationSetting.last_update
    
    series_ids, episodes_ids, b_time = tvdb.get_updates(a_time)
    series_ids.each do |serie_id|
      serie = Series.find_by_tvdb_id(serie_id)
      s = tvdb.get_series_by_id(serie_id)
      p "The serie #{s.name} has been updated since #{Time.at(a_time.to_i)}"
      if serie.nil?
        p "It has not been saved in the database. Skipping."
      else
        p "It has been saved in the database. Updating."
      end
      unless serie.nil?
        serie.update_attributes(:name => s.name, :series_id => s.id,
                                :description => s.overview,
                                :first_aired => s.first_aired, :network => s.network,
                                :rating => s.rating, :runtime => s.runtime,
                                :status => s.status == "Continuing",
                                :imdb_id => s.imdb_id,
                                :rating_count => s.rating_count,
                                :air_time => s.air_time, :air_day => s.air_day,
                                :poster_url => s.poster)
      end
    end
    
    episodes_ids.each do |episode_id|
      e = tvdb.get_episode_by_id(episode_id)
      s = tvdb.get_series_by_id(e.seriesid)
      p "The episode #{s.name} S#{e.season_number.rjust(2, '0')}E#{e.episode_number.rjust(2, '0')} has been updated since #{Time.at(a_time.to_i)}"
      episode = Episode.find_by_tvdb_id(episode_id)
      if episode.nil?
        p "The episode has never been saved in the database. Checking for series name."
        serie = Series.find_by_tvdb_id(s.id)
        if serie.nil?
          p "This episode is from the serie #{s.name}. Not present in the database. Skipping."
        else
          p "This episode is from the serie #{s.name}. Looking for the season."
          season = Season.find_by_tvdb_id(e.season_id.to_i)
          
          if season.nil?
            p "This episode is new. From a new season. Adding the season and the episode"
            season = serie.seasons.build(:tvdb_id => ep.season_id.to_i,
                                         :number => e.season_number,
                                         :poster_processing => true)
            season.poster_url = s.season_posters(season.number).first.path unless s.season_posters(season.number).first.nil?
          else
            p "This episode is new. From an existing season. Adding the episode to the season"
          end
          season.episodes << Episode.new(:tvdb_id => ep.id, :number => ep.number,
                                :name => ep.name, :description => ep.overview,
                                :director => ep.director, :writer => ep.writer,
                                :first_aired => ep.air_date, :poster_url => ep.thumb,
                                :poster_processing => true)
          season.save
        end
      else
        p "The episode has been found. Updating."
        episode.update_attributes(:tvdb_id => e.id, :number => e.number,
                                  :name => e.name, :description => e.overview,
                                  :director => e.director, :writer => e.writer,
                                  :first_aired => e.air_date,
                                  :poster_url => e.thumb)
      end
    end
    
    p "The series have been updated at #{Time.at(b_time.to_i)}"
    ApplicationSetting.last_update = b_time
    ApplicationSetting.save
  end
end