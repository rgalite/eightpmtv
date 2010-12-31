namespace :tvdb do
  desc "Download images from tvdb to Amazon S3"
  task :download_banners => :environment do |t, args|
    unless ENV['BANNERS'].nil?
      puts "Loading Amazon S3 configuration ..."
      s3_config = YAML.load_file(File.join(Rails.root, "config", "amazon_s3.yml"))
      AWS::S3::Base.establish_connection!(
        :access_key_id     => s3_config[Rails.env]["access_key_id"],
        :secret_access_key => s3_config[Rails.env]["secret_access_key"]
      )
      puts "Done."
      
      banners = ENV['BANNERS'].split('|')
      puts "Found #{banners.size} banners"
      banners.each_with_index do |banner_path, idx|
        begin
          puts "Loading banner n.#{idx + 1}"
          banner_s3_path = "assets/#{banner_path}"
          banner_url = "http://thetvdb.com/banners/#{banner_path}"
          puts "Banner PATH : #{banner_path}"
          puts "Banner URL : #{banner_url}"
          puts "Banner S3 PATH : #{banner_s3_path}"
          banner = AWS::S3::S3Object.find(banner_s3_path, "rmgalite-tvshows")
          puts "Banner already exists in S3"
        rescue
          puts "Banner does not exists in S3"
          AWS::S3::S3Object.store(banner_s3_path, open(banner_url), 'rmgalite-tvshows',
                                  :access => :private)
          puts "Banner is saved in S3"
        end
      end
    end
  end
  
  desc "Attach poster to series"
  task :attach_poster_to_series => :environment do |t, args|
    Series.all.each do |serie|
      p "Attaching poster for serie #{serie.name} (ID = #{serie.id}, TVDB_ID = #{serie.tvdb_id})"
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      s = tvdb.get_series_by_id(serie.tvdb_id)

      unless s.nil? or serie.nil?
        serie.poster_url = s.poster

        serie.save
      end
      p "Done"
    end
    puts "Done."
  end
  
  desc "Attach avatar to role"
  task :attach_avatar_to_role => :environment do |t, args|
    File.open("toto.txt", "r") do |file|
      file.each do |line|
        info = line.split(/\t+/)
        role = Role.find(info[0].to_i)
        unless info[1].blank?
          role.image_url = info[2]
          if role.save
            puts "Role #{role.name} in series #{role.series.name} has been updated (ID = #{role.id})" 
          else
            puts "Role #{role.name} in series #{role.series.name} has not been updated (ID = #{role.id})"
            puts "=> Errors #{role.errors.full_messages}"
            puts "Destroyed"
            role.destroy
          end
        end
      end
    end
    puts "Done."
  end
  
  desc "Attach missing poster to season (when deleted from Amazon S3)"
  task :redownload_missing_season_poster => :environment do |t, args|
    seasons = Season.all.find_all { |s| !s.poster.url.nil? && !s.poster.exists? }
    seasons.each do |season|
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      serie = tvdb.get_series_by_id(season.series.tvdb_id)
      
      p "Found #{season.series.name} S#{season.number.to_s.rjust(2, '0')}"
    end
  end
end