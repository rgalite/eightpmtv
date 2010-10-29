s3_config = YAML.load_file(File.join(Rails.root.to_s, "config", "amazon_s3.yml"))

AWS::S3::Base.establish_connection!(
  :access_key_id     => s3_config[Rails.env]["access_key_id"],
  :secret_access_key => s3_config[Rails.env]["secret_access_key"]
)
