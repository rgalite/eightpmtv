require 'aws/s3'
require 'digest/md5'
require 'mime/types'
## These are some constants to keep track of my S3 credentials and 
## bucket name. Nothing fancy here.    

EXCLUDED_FOLDERS = %w{ static }


## This defines the rake task `assets:deploy`. 
namespace :assets do  
  desc "Deploy all assets in public/**/* to S3/Cloudfront"
  task :deploy, :env, :branch do |t, args|

## Minify all CSS files 
    # Rake::Task[:minify].execute

## Use the `s3` gem to connect my bucket
    puts "== Uploading assets to S3/Cloudfront"
    s3_config = YAML.load_file(File.join(Rails.root, 'config', 'amazon_s3.yml'))[Rails.env]
    AWS::S3::Base.establish_connection!(
      :access_key_id => s3_config["access_key_id"],
      :secret_access_key => s3_config["secret_access_key"])
    bucket = AWS::S3::Bucket.find(s3_config["assets_bucket"])

## Needed to show progress
    STDOUT.sync = true

## Find all files (recursively) in ./public and process them.
    
    Dir.glob("public/**/*").reject{|file| EXCLUDED_FOLDERS.any?{|folder| file.starts_with?("public/#{folder}")}}.each do |file|

## Only upload files, we're not interested in directories
      if File.file?(file)

## Slash 'public/' from the filename for use on S3
        remote_file = file.gsub("public/", "")

## Try to find the remote_file, an error is thrown when no
## such file can be found, that's okay.  
        begin
          obj = bucket[remote_file]
        rescue
          obj = nil
        end

## If the object does not exist, or if the MD5 Hash / etag of the 
## file has changed, upload it.
        if !obj || (obj.etag != Digest::MD5.hexdigest(File.read(file)))
            print "U"

## Simply create a new object, write the content and set the proper 
## mime-type. `obj.save` will upload and store the file to S3.
            AWS::S3::S3Object.store(
                remote_file,
                open(file),
                bucket.name,
                :content_type => MIME::Types.type_for(file).to_s
              )
        else
          print "."
        end
      end
    end
    STDOUT.sync = false # Done with progress output.

    puts
    puts "== Done syncing assets"
  end
end