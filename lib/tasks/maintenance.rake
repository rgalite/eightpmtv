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
  
  desc "Update users image"
  task :update_follow_activities => [:environment] do |t, args|
    activities = Activity.where(:kind => "follow_user")
    activities.each_with_index do |activity, i|
      user = activity.subject.followable
      activity_data = JSON.parse(activity.data)
      activity_data[:user_img] = user.avatar_url(:thumb)

      # Get the series the user is following
      activity_data[:user_series] = user.series.all.randomly_pick(5).collect{|serie| { :name => serie.full_name, :path => show_path(serie)}}
      activity_data[:user_series_count] = user.series.count

      # Get the people who are following the user
      activity_data[:user_followers] = user.followers.randomly_pick(5).collect{|follower| { :name => follower.full_name, :path => user_path(follower), :img => follower.avatar_url(:thumb)}}
      activity_data[:user_followers_count] = user.followers.count

      # Get the people the user is following
      activity_data[:user_followings] = user.following_by_type('User').randomly_pick(5).collect{|follower| { :name => follower.full_name, :path => user_path(follower), :img => follower.avatar_url(:thumb)}}
      activity_data[:user_followings_count] = user.following_by_type('User').count

      activity.update_attributes(:data => activity_data.to_json)
      
      puts "Activity #{i + 1} / #{activities.count}"
    end
  end
end