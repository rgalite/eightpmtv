class User < ActiveRecord::Base
  has_many :authentications, :dependent => :destroy
  has_many :series, :through => :subscriptions, :order => "name"
  has_friendly_id :username, :use_slug => true, :approximate_ascii => true,
                  :max_length => 50  
  has_many :comments, :dependent => :nullify
  has_many :likes
  has_settings
  acts_as_follower
  acts_as_followable
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation,
                  :remember_me, :login, :photo, :captcha,
                  :settings_use_avatar
  attr_accessor :login, :captcha,
                :settings_use_avatar
  
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
    
  protected
  def self.find_for_database_authentication(conditions)
   login = conditions.delete(:login)
   where(conditions).where(["username = :value OR email = :value", { :value => login }]).first
  end
  
  def update_settings
    if ["own", "gravatar"].include?(@settings_use_avatar)
      settings.use_avatar = @settings_use_avatar
    end
  end
  
  def create_settings
    settings.use_avatar = "own"
  end
  
  def update_activities_avatar
    Delayed::Job.enqueue(AttachImageToActorActivitiesJob.new(id))
  end
end
