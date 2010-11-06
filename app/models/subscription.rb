class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :series
  
  validates_presence_of :user_id, :series_id
  validates_uniqueness_of :series_id, :scope => [:user_id]
end
