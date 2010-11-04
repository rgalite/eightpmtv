class User < ActiveRecord::Base
  has_many :authentications
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me

  validates_presence_of :username
  validates_uniqueness_of :username
  validates_length_of :username, :in => 4..12

  def apply_omniauth(omniauth)
    self.authentications.build(:provider => omniauth["provider"], :uid => omniauth["uid"])
  end
  
  def password_required?
    (authentications.empty? || !password.blank?) && super
  end
end
