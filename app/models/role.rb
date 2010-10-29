class Role < ActiveRecord::Base
  belongs_to :series
  belongs_to :actor
  
  def image_url
    @image_url ||= AWS::S3::S3Object.find("assets/#{self.image}", "rmgalite-tvshows").url
  end
end
