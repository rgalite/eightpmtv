class Series < ActiveRecord::Base
  include CallRake
  has_many :roles, :dependent => :destroy
  has_many :actors, :through => :roles, :order => "name ASC"
  has_many :comments, :as => :commentable, :order => "created_at desc"
  has_many :subscriptions
  has_many :watchers, :through => :subscriptions, :source => :user
  has_many :episodes
  has_friendly_id :name, :use_slug => true, :approximate_ascii => true,
                  :max_length => 50
  has_and_belongs_to_many :genres, :order => "name ASC"
  has_attached_file :poster,
                    :styles => { :small => "150x220>", :medium => "204x300>" },
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                    :bucket => "static.eightpm.tv",
                    :path => "assets/series/:attachment/:id/:style/:basename.:extension",
                    :s3_permissions => :public_read,
                    :s3_host_alias => "static.eightpm.tv",
                    :url => ":s3_alias_url"

  has_many :likes, :as => :likeable
  process_in_background :poster
  
  public  
  def set_actors(actors)
    p "\n\nSETTING THE ACTORS\n\n"
    actors.each_with_index do |a, i|
      actor = Actor.find_or_initialize_by_name(:name => a.name, :tvdb_id => a.id)
      role = Role.new(:actor => actor, :name => a.role, :image_url => a.image)
      p "\n\nSETTING THE ACTOR n.#{i+1}\n\n"
      self.roles << role if role.valid?
    end
  end
  
  def poster_url=(poster_url)
    self.poster = RemoteFile.new("http://thetvdb.com/banners/#{poster_url}")
  end
end
