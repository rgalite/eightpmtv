class Role < ActiveRecord::Base
  belongs_to :series
  belongs_to :actor
  
  has_friendly_id :name, :use_slug => true, :approximate_ascii => true,
                  :max_length => 50, :scope => :series

  validates_presence_of :name

  has_attached_file :image,
                    :storage => :s3,
                    :styles => { :small => "100x150>" },
                    :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                    :bucket => "static.eightpm.tv",
                    :path => "assets/series/:attachment/:id/:style/:basename.:extension",
                    :s3_permissions => :public_read,
                    :s3_host_alias => "static.eightpm.tv",
                    :url => ":s3_alias_url"
  
  has_many :likes, :as => :likeable
  process_in_background :image
  
  def image_url=(image_url)
    self.image = RemoteFile.new("http://thetvdb.com/banners/#{image_url}")
  end
end
