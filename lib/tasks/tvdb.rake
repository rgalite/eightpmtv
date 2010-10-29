namespace :tvdb do
  desc "Download images from tvdb to Amazon S3"
  task :download_banners => :environment do |t, args|
    unless ENV['BANNERS'].nil?
      puts "Loading Amazon S3 configuration ..."
      s3_config = YAML.load_file(File.join(RAILS_ROOT, "config", "amazon_s3.yml"))
      AWS::S3::Base.establish_connection!(
        :access_key_id     => s3_config[RAILS_ENV]["access_key_id"],
        :secret_access_key => s3_config[RAILS_ENV]["secret_access_key"]
      )
      puts "Done."
      
      banners = ENV['BANNERS'].split('|')
      puts "Found #{banners.size} banners"
      banners.each_with_index do |banner_url, idx|
        begin
          puts "Loading banner n.#{idx + 1}"
          banner_url = "http://thetvdb.com/banners/#{banner_url}"
          puts "Banner URL : #{banner_url}"
          banner_s3_path = "assets/#{banner_url}"
          puts "Banner S3 PATH : #{banner_s3_path}"
          banner = AWS::S3::S3Object.find(banner_s3_path, "rmgalite-tvshows")
          puts "Banner already exists in S3"
        rescue
          puts "Banner does not exists in S3"
          AWS::S3::S3Object.store(banner_s3_path, open(banner_url), 'rmgalite-tvshows',
                                  :access => :public_read)
          puts "Banner is saved in S3"
        end
      end
    end
  end
end