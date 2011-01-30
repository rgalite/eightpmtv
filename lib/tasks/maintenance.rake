namespace :maintenance do
  desc "Restore episodes that poster has not been processed but marked as processing"
  task :restore_episode_poster => :environment do
    episodes = Episode.where("poster_file_name IS NULL")
    puts "#{episodes.count} episodes to update"
    episodes.each_with_index do |episode, i|
      puts "Updating #{episode.full_name} (#{i + 1}/#{episodes.count})"
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      tvdb_episode = tvdb.get_episode_by_series_id_season_number_and_episode_number(episode.series.tvdb_id,
                    episode.season.number, episode.number)
      if tvdb_episode && !tvdb_episode.thumb.blank?
        puts "Poster url: #{tvdb_episode.thumb}"
        puts "Episode: #{episode.update_attributes(:poster_url => tvdb_episode.thumb) ? 'updated' : 'failed'}"
      end 
    end
  end
end