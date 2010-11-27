class Series < ActiveRecord::Base
  include CallRake
  has_many :roles, :dependent => :destroy
  has_many :actors, :through => :roles
  has_many :comments, :as => :commentable, :order => "created_at desc"
  has_many :subscriptions
  has_friendly_id :name, :use_slug => true, :approximate_ascii => true,
                  :max_length => 50
      
  has_attached_file :poster,
                    :styles => { :small => "150x220>", :medium => "204x300>" },
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                    :path => "assets/series/:attachment/:id/:style/:basename.:extension"
  
  public  
  def set_actors(actors)
    actors.each do |a|
      actor = Actor.find_or_initialize_by_name(:name => a.name, :tvdb_id => a.id)
      role = Role.new(:actor => actor, :name => a.role, :image_url => a.image)
      self.roles << role if role.valid?
    end
  end
  
  def poster_url=(poster_url)
    self.poster = RemoteFile.new("http://thetvdb.com/banners/#{poster_url}")
  end
end
