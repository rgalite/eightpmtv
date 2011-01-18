include Rails.application.routes.url_helpers
namespace :app do
  desc "Look for updates and update the current database [activity=true/false,update_type=all/day/month]"
  task :update_database_with_tvdb, :activity, :update_type, :needs => :environment do |t, args|
    begin
      args.with_defaults(:activity => false, :update_type => nil)
      puts "Updating the database with options activity=#{args.activity} and update_type=#{args.update_type}"
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      a_time = Settings.last_update.to_i
      if args.update_type.nil?
        series_ids, episodes_ids, b_time = tvdb.get_updates(a_time)
        raise "The last update ran more than 24 hours earlier (#{Time.at a_time} - #{Time.at b_time}). Run a full update." if b_time - a_time > 86400
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
          serie.update_attributes!(:name => s.name, :series_id => s.id,
                                   :description => s.overview,
                                   :first_aired => s.first_aired,
                                   :network => s.network,
                                   :rating => s.rating, :runtime => s.runtime,
                                   :status => s.status == "Continuing",
                                   :imdb_id => s.imdb_id,
                                   :rating_count => s.rating_count,
                                   :air_time => s.air_time, :air_day => s.air_day)
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
                  season.save!
                end

                # The season exists now. Add the episode
                episode = season.episodes.create!(:tvdb_id => ep.id,
                                                  :number => ep.number,
                                                  :name => ep.name,
                                                  :description => ep.overview,
                                                  :director => ep.director,
                                                  :writer => ep.writer,
                                                  :first_aired => ep.air_date,
                                                  :poster => RemoteFile.new("http://thetvdb.com/banners/#{ep.thumb}"))
                puts "Episode #{episode.full_name}. Created."
                if args.activity
                  # The episode is scheduled
                  puts "Episode #{episode.full_name} is scheduled."
                  Activity.delay(:priority => 10).create!(:actor => episode.series,
                                    :actor_name => episode.series.full_name,
                                    :actor_img => episode.series.poster.url(:thumb),
                                    :actor_path => show_path(episode.series),
                                    :subject => episode,
                                    :kind => "new_episode_scheduled",
                                    :data => { :episode_name => episode.full_name,
                                               :episode_path => show_season_episode_path(:show_id => episode.series.id,
                                                                                       :season_number => episode.season.number,
                                                                                       :episode_number => episode.number),
                                               :season_number => episode.season.number,
                                               :episode_number => episode.number,
                                               :episode_time => episode.first_aired }.to_json)
                end
                episodes_updated[:new] << episode
              else
                if ep.last_updated.to_i >= a_time
                  available = episode.available? 
                  episode.update_attributes!(:tvdb_id => ep.id,
                                            :number => ep.number,
                                            :name => ep.name,
                                            :description => ep.overview,
                                            :director => ep.director,
                                            :writer => ep.writer,
                                            :first_aired => ep.air_date,
                                            :poster_url => ep.thumb)
                  if args.activity && !available && episode.available? # The episode is NOW available
                    puts "Episode #{episode.full_name} is now available."
                    Activity.create!(:actor_name => episode.full_name,
                                      :actor_img => episode.poster.url(:thumb),
                                      :actor_path => show_season_episode_path(:show_id => episode.series.id,
                                                                               :season_number => episode.season.number,
                                                                               :episode_number => episode.number),
                                      :kind => "new_episode_available",
                                      :data => { :episode_description => episode.description }.to_json)
                  end
                  puts "Episode #{episode.full_name}. Updated."
                  episodes_updated[:updated] << episode
                end
              end
            end
          end
        end
      end

      puts "The series have been updated at #{Time.at(b_time.to_i)}"
      results = "#{series_updated.size} series updated. #{episodes_updated[:new].size} new episodes. #{episodes_updated[:updated].size} episodes updated."
      puts results
      AdminMailer.deliver_series_update_succeeded(results) unless %w{ test development }.include?(Rails.env)
      Settings.last_update = b_time.to_s
    rescue Exception => e
      AdminMailer.deliver_series_update_failed(e.message + ":\n" + e.backtrace.join("\n")) unless %w{ test development }.include?(Rails.env)
      raise e
    end
  end
end