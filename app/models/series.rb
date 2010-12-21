class Series < ActiveRecord::Base
  include CallRake
  has_many :roles, :dependent => :destroy
  has_many :actors, :through => :roles, :order => "name ASC"
  has_many :comments, :as => :commentable, :order => "created_at desc"
  has_many :subscriptions, :dependent => :destroy
  has_many :watchers, :through => :subscriptions, :source => :user
  has_many :episodes, :dependent => :destroy
  has_friendly_id :name, :use_slug => true, :approximate_ascii => true,
                  :max_length => 50
  has_and_belongs_to_many :genres, :order => "name ASC"
  has_attached_file :poster, {
                      :styles => { :small => "150x220>", :medium => "204x300>" },
                    }.merge(Tvshows::Application.config.paperclip_options)
  has_many :likes, :as => :likeable, :dependent => :destroy
  has_many :seasons, :dependent => :destroy, :order => "number ASC"
  has_many :episodes, :through => :seasons
  process_in_background :poster
  
  public  
  def set_actors(actors)
    actors.each_with_index do |a, i|
      actor = Actor.find_or_initialize_by_name(:name => a.name, :tvdb_id => a.id)
      role = Role.new(:actor => actor, :name => a.role, :image_url => a.image)
      self.roles << role if role.valid?
    end
  end
  
  def poster_url=(poster_url)
    self.poster = RemoteFile.new("http://thetvdb.com/banners/#{poster_url}")
  end
end
