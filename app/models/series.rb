class Series < ActiveRecord::Base
  include CallRake
  has_many :roles, :dependent => :destroy
  has_many :actors, :through => :roles
    
  has_attached_file :poster,
                    :styles => { :small => "150x220>", :medium => "204x300>" },
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                    :path => "assets/series/:attachment/:id/:style/:basename.:extension"
  
  public
  def to_param
    return "#{self.id}-#{self.name.parameterize}"
  end
  
  def set_actors(actors)
    actors.each do |a|
      actor = Actor.find_or_initialize_by_name(:name => a.name, :tvdb_id => a.id)
      role = Role.new(:actor => actor, :name => a.role, :image => a.image)
      self.roles << role
            
      call_rake "tvdb:download_banners", { :banners => a.image }
    end
  end
  
  def banner_url
    begin
      @banner_url ||= AWS::S3::S3Object.find("assets/#{self.banner}", "rmgalite-tvshows").url
    rescue
      self.banner
    end
  end
  
  def poster_url
    begin
      @poster_url ||= AWS::S3::S3Object.find("assets/#{self.poster}", "rmgalite-tvshows").url
    rescue
      self.poster
    end
  end
  
  def fanart_url
    begin
      @fanart_url ||= AWS::S3::S3Object.find("assets/#{self.fanart}", "rmgalite-tvshows").url
    rescue
      self.fanart
    end
  end
end
