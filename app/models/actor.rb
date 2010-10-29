class Actor < ActiveRecord::Base
  has_many :roles, :dependent => :destroy
  has_many :series, :through => :roles
end
