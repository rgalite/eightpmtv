class User < ActiveRecord::Base
  has_many :authentications, :dependent => :destroy
  has_many :subscriptions, :dependent => :destroy
  has_many :series, :through => :subscriptions, :order => "name"
  has_friendly_id :username, :use_slug => true, :approximate_ascii => true,
                  :max_length => 50  
  has_many :comments, :dependent => :nullify
  has_many :friendships, :dependent => :destroy
  has_many :friends, :through => :friendships
  has_many :likes
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me

  validates_presence_of :username
  validates_uniqueness_of :username
  validates_length_of :username, :in => 2..24

  def apply_omniauth(omniauth)
    authentication = self.authentications.build(:provider => omniauth["provider"],
                                                :uid => omniauth["uid"])
    case omniauth["provider"]
    when "twitter"
      self.username = omniauth["user_info"]["nickname"] if self.username.blank?
      authentication.avatar = omniauth["user_info"]["image"]
    when "facebook"
      self.email = omniauth["user_info"]["email"] if self.email.blank?
    end
  end
  
  def password_required?
    (authentications.empty? || !password.blank?) && super
  end
  
  def watch?(series)
    series.subscriptions.any?{ |s| s.user == current_user }
  end
  
  def friends_watching(series)
    fw = []
    series.subscriptions.collect{ |s| fw << s.user if friends.include?(s.user) }
    fw
  end
  
  def is_a_friend_of?(user)
    user.friends.include?(self)
  end
  
  def avatar_url
    if !authentications.first.nil? && !authentications.first.avatar.nil?
    else
      "/images/user-default-icon.png"
    end
  end
  
  def likes?(item)
    !likes.detect{ |l| l.likeable == item && l.value > 0 }.nil?
  end
  
  def dislikes?(item)
    !likes.detect{ |l| l.likeable == item && l.value < 0 }.nil?
  end
end
