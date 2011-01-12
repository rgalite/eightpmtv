require 'lib/colorize_string'
namespace :app do
  desc "Look for updates and update the current database [activity=true/false,update_type=all/day/month]"
  task :update_database_with_tvdb, :activity, :update_type, :needs => :environment do |t, args|
    args.with_defaults(:activity => false, :update_type => nil)
    puts "Updating the database with options activity=#{args.activity} and update_type=#{args.update_type}"
    tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
    a_time = Settings.last_update.to_i
    if args.update_type.nil?
      series_ids, episodes_ids, b_time = tvdb.get_updates(a_time)
      raise "The last update ran more that 24 hours earlier (#{Time.at a_time} - #{Time.at b_time}). Run a full update." if b_time - a_time > 86400
    else
      series_ids, episodes_ids, b_time = tvdb.get_updates(a_time,
                                            :update_type => args.update_type)
    end

    series_updated = []
    episodes_updated = { :new => [], :updated => [] }

    series_ids.each_with_index do |serie_id, index|
      serie = Series.find_by_tvdb_id(serie_id)
      puts "Processing serie #{serie_id} (#{index + 1}/#{series_ids.size})"
      if !serie.nil?
        s = tvdb.get_series_by_id(serie_id)
        puts "Updating the serie #{serie.name}."
        serie.update_attributes(:name => s.name, :series_id => s.id,
                                :description => s.overview,
                                :first_aired => s.first_aired,
                                :network => s.network,
                                :rating => s.rating, :runtime => s.runtime,
                                :status => s.status == "Continuing",
                                :imdb_id => s.imdb_id,
                                :rating_count => s.rating_count,
                                :air_time => s.air_time, :air_day => s.air_day,
                                :poster_url => s.poster)
        series_updated << serie
        episodes = s.episodes
        episodes.each_with_index do |ep, i|
          if !ep.season_number.strip.to_i.zero? && !ep.number.strip.to_i.zero?
            episode = serie.episodes.find_by_tvdb_id(ep.id)

            # The episode does not exist
            if episode.nil? 
              puts "The episode has never been saved in the database. This is a new episode!"
              season = serie.seasons.find_by_tvdb_id(ep.season_id.to_i)

              # The season does not exist. It's a new season
              if season.nil?
                puts "New season!"
                season = serie.seasons.build(:tvdb_id => ep.season_id.to_i,
                :number => ep.season_number)
                s = tvdb.get_series_by_id(ep.series_id)
                season.poster_url = s.season_posters(season.number).first.path unless s.season_posters(season.number).first.nil?
              end

              # The season exists now. Add the episode
              episode = season.episodes.build(:tvdb_id => ep.id,
                                              :number => ep.number,
                                              :name => ep.name,
                                              :description => ep.overview,
                                              :director => ep.director,
                                              :writer => ep.writer,
                                              :first_aired => ep.air_date,
                                              :poster_url => ep.thumb)
              episode.save
              puts "Processing new episode #{episode.full_name}. Saved.".to_color("green")
              episodes_updated[:new] << episode
            else
              if ep.last_updated.to_i >= a_time 
                puts "Episode found. #{episode.full_name}. Updated.".to_color("green")
                episode.update_attributes(:tvdb_id => ep.id,
                                          :number => ep.number,
                                          :name => ep.name,
                                          :description => ep.overview,
                                          :director => ep.director,
                                          :writer => ep.writer,
                                          :first_aired => ep.air_date,
                                          :poster_url => ep.thumb)
                episodes_updated[:updated] << episode
              end
            end
          end
        end
      end
    end

    puts "The series have been updated at #{Time.at(b_time.to_i)}"
    puts "#{series_updated.size} series updated. #{episodes_updated[:new].size} new episodes. #{episodes_updated[:updated].size} episodes updated."
    Settings.last_update = b_time.to_s
  end
end