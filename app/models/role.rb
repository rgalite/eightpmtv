class Role < ActiveRecord::Base
  belongs_to :series
  belongs_to :actor
  
  validates_presence_of :name

  has_attached_file :image,
                    :storage => :s3,
                    :styles => { :small => "100x150>" },
                    :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                    :path => "assets/series/:attachment/:id/:style/:basename.:extension"
  
  def image_url=(image_url)
    self.image = RemoteFile.new("http://thetvdb.com/banners/#{image_url}")
  end
end
