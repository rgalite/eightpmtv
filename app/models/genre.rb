class Genre < ActiveRecord::Base
  validates :name, :presence => true
  
  has_and_belongs_to_many :series, :order => "name ASC"
  has_friendly_id :name, :use_slug => true, :approximate_ascii => true,
                  :max_length => 50
end
