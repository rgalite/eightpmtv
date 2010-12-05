class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  has_many :likes, :as => :likeable
  validates :content, :presence => true, :length => { :within => 10..500 }
  
  before_validation :strip_whitespace
  
  def strip_whitespace
    self.content.strip!
  end
end
