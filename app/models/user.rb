class User < ActiveRecord::Base
  has_many :authentications, :dependent => :destroy
  has_many :series, :through => :subscriptions, :order => "name"
  has_friendly_id :username, :use_slug => true, :approximate_ascii => true,
                  :max_length => 50  
  has_many :comments, :dependent => :nullify
  has_many :likes
  has_many :ratings
  
  has_settings
  acts_as_follower
  acts_as_followable
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :username, :password, :password_confirmation,
                  :remember_me, :login, :photo, :captcha,
                  :settings_use_avatar, :settings_notification_episode_available,
                  :settings_notification_episode_scheduled
  attr_accessor :login, :captcha,
                :settings_use_avatar, :settings_notification_episode_available,
                :settings_notification_episode_scheduled
  attr_readonly :username
  
  validates_presence_of :username
  validates_uniqueness_of :username
  validates_length_of :username, :in => 2..12
  has_attached_file :photo, {
                      :styles => { :medium => "128x128#", :thumb => "48x48#", :small => "20x20#" },
                      :default_url => "/images/user_default_icon_:style.png"
                    }.merge(Tvshows::Application.config.paperclip_options)
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/jpg', 'image/png']
  validates_attachment_size :photo, :less_than => 2.megabytes
  has_many :activities, :dependent => :destroy, :as => :actor
  has_many :inv_activities, :class_name => "Activity", :dependent => :destroy, :as => :subject
  has_many :seens
  has_many :seasons_seen, :through => :seens, :source => :seenable,
           :source_type  => "Season", :order => "number ASC"
  has_many :episodes_seen, :through => :seens, :source => :seenable,
           :source_type  => "Episode", :include => :season,
           :order => "episodes.number ASC, seasons.number ASC"

  after_save :update_settings, :update_activities_avatar
  before_create :create_settings
  attr_readonly :follows_count
  def apply_omniauth(omniauth)
    authentication = self.authentications.build(:provider => omniauth["provider"],
                                                :uid => omniauth["uid"])
    self.username = omniauth["user_info"]["nickname"] if self.username.blank?
    authentication.avatar = omniauth["user_info"]["image"]
    self.email = omniauth["user_info"]["email"] if self.email.blank?
  end
    
  def password_required?
    (authentications.empty? || !password.blank?) && super
  end
  
  def watch?(series)
    self.following?(series)
  end

  def followings_watching(series)
    series.watchers.find_all{ |w| following?(w) }
  end
      
  def avatar_url(style = nil)
    if settings.use_avatar == "gravatar"
      gravatar_url(style)
    else
      photo.url(style ||= :medium)
    end
  end
  
  def gravatar_url(style = nil)
    style ||= :medium
    styles = { :medium => 128, :thumb => 48, :small => 20 }
    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{styles[style]}&r=g"
  end
  
  def likes?(item)
    !likes.detect{ |l| l.likeable == item && l.value > 0 }.nil?
  end
  
  def dislikes?(item)
    !likes.detect{ |l| l.likeable == item && l.value < 0 }.nil?
  end
  def update_with_password(params={}) 
    if params[:password].blank? 
      params.delete(:password) 
      params.delete(:password_confirmation) if params[:password_confirmation].blank? 
    end 
    update_attributes(params) 
  end
  
  def name
    username
  end
  
  def full_name
    username
  end
  
  def series
    following_series
  end
  
  def has_settings?(settingz)
    !settings[settingz].nil?
  end
  
  def join_date
    created_at.to_date
  end
  
  def as_json(options = {})
    options.merge!(:methods => [ :image_url_small, :full_name, :join_date ],
                   :only => [ :full_name, :image_url_small ]){ |key, v1, v2| v1 + v2 }
    super(options)
  end
  
  def users_followers_json
    users_followers.as_json(:only => [ :full_name, :image_url_small ], :methods => [ :image_url_small, :full_name ])
  end
  
  def following_users_json
    following_users.as_json(:only => [ :full_name, :image_url_small ], :methods => [ :image_url_small, :full_name ])
  end
  
  def as_json_with_followers_and_followings
    series_h = { :methods => [ :poster_url_small, :full_name ], :only => [ :full_name, :poster_url_small ] }
    options = { :methods => [ :join_date, :users_followers_json, :following_users_json ],
                :include => {
                              :series => series_h
                            },
                :only => [ :join_date ] }
    as_json(options)
  end
  
  def image_url_small
    avatar_url(:small)
  end
  
  def self.find_by_name(name)
    self.find_by_username(name)
  end

  def has_watched?(seenable)
    if seenable.class.to_s == "Episode"
      seasons_seen.any?{ |season| season.id == seenable.season.id } || episodes_seen.any?{ |episode| episode.id == seenable.id }
    elsif seenable.class.to_s == "Season"
      seasons_seen.any?{ |season| season.id == seenable.season.id } || !seenable.episodes.available.any?{ |episode| !has_watched?(episode) }
    else
      seens.any? { |s| s.seenable_id == seenable.id && s.seenable_type == seenable.class.to_s  }
    end
  end
  
  def has_seen?(seenable)
    has_watched?(seenable)
  end
  
  def rating_for(rateable)
    rating = ratings.where(["rateable_id = ? AND rateable_type = ?", rateable.id, rateable.class.to_s]).first
    if rating
      rating.value
    else
      0
    end
  end
    
  protected
  def self.find_for_database_authentication(conditions)
   login = conditions.delete(:login)
   where(conditions).where(["username = :value OR email = :value", { :value => login }]).first
  end
  
  def update_settings
    if ["own", "gravatar"].include?(@settings_use_avatar)
      settings.use_avatar = @settings_use_avatar
    end
    settings.notification_episode_available = @settings_notification_episode_available
    settings.notification_episode_scheduled = @settings_notification_episode_scheduled
  end
  
  def create_settings
    settings.use_avatar = "own"
  end
  
  def update_activities_avatar
    Delayed::Job.enqueue(AttachImageToUserActivitiesJob.new(id))
  end
end
