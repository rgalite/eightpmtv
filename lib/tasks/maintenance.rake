namespace :maintenance do
  desc "Restore episodes that poster has not been processed but marked as processing"
  task :restore_episode_poster => :environment do
    episodes = Episode.where(["poster_file_name IS NULL OR poster_processing = ?", true])
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
  
  desc "Update images to new path"
  task :update_s3_poster_path => :environment do |t, args|
    require 'aws/s3'
    s3_config = YAML.load_file(File.join(Rails.root, 'config', 'amazon_s3.yml'))[Rails.env]
    AWS::S3::Base.establish_connection!(
       :access_key_id     => s3_config["access_key_id"],
       :secret_access_key => s3_config["secret_access_key"]
    )
    eightpm_bucket = AWS::S3::Bucket.find(s3_config["bucket"])
    puts "There are #{eightpm_bucket.objects.size} objects in the eightpm bucket"
  end
end