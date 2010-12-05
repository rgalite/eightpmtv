class Actor < ActiveRecord::Base
  has_many :roles, :dependent => :destroy
  has_many :series, :through => :roles
  
  has_friendly_id :name, :use_slug => true, :approximate_ascii => true,
                  :max_length => 50
  has_many :likes, :as => :likeable
end
