class User < ActiveRecord::Base
  has_many :authentications
  has_many :subscriptions
  has_many :series, :through => :subscriptions
  has_friendly_id :username, :use_slug => true, :approximate_ascii => true,
                  :max_length => 50  
  has_many :comments, :dependent => :nullify
  has_many :friendships
  has_many :friends, :through => :friendships
  
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
    self.authentications.build(:provider => omniauth["provider"],
                               :uid => omniauth["uid"])
    if (omniauth["provider"] == "twitter")
      self.username = omniauth["user_info"]["nickname"]
    end
  end
  
  def password_required?
    (authentications.empty? || !password.blank?) && super
  end
end
