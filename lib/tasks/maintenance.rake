namespace :maintenance do
  desc "Restore episodes that poster has not been processed but marked as processing"
  task :restore_episode_poster => :environment do
    Episode.where(["poster_file_name IS NULL AND poster_processing = ?", true]).each do |episode|
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      tvdb_episode = tvdb.get_episode_by_id(episode.tvdb_id)
      episode.update_attribute(:poster_url, tvdb_episode.thumb) if tvdb_episode
    end
  end
end