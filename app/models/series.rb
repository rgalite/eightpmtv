class Series < ActiveRecord::Base
  include CallRake
  has_many :roles, :dependent => :destroy
  has_many :actors, :through => :roles
    
  private
  def get_actor_img(actor_link)
    unless actor_link.nil?
      begin
        banner_url = "http://thetvdb.com/banners/#{actor_link}"
        banner_s3_path = "assets/#{actor_link}"
        banner = AWS::S3::S3Object.find(banner_s3_path, "rmgalite-tvshows")
      rescue
        AWS::S3::S3Object.store(banner_s3_path, open(banner_url), 'rmgalite-tvshows',
                                :access => :public_read)
        banner = AWS::S3::S3Object.find(banner_s3_path, "rmgalite-tvshows")
      ensure
        return banner.url
      end                              
    end
  end
  
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
    @banner_url ||= AWS::S3::S3Object.find("assets/#{self.banner}", "rmgalite-tvshows")
  end
  
  def poster_url
    @poster_url ||= AWS::S3::S3Object.find("assets/#{self.poster}", "rmgalite-tvshows")
  end
  
  def fanart_url
    @fanart_url ||= AWS::S3::S3Object.find("assets/#{self.fanart}", "rmgalite-tvshows")
  end
end
