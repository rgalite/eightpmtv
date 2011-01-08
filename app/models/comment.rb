class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  has_many :votes, :as => :likeable, :class_name => "Like"
  has_many :activities, :as => :subject, :dependent => :destroy
  validates :content, :presence => true, :length => { :within => 10..500 }
  
  before_validation :strip_whitespace
  
  def strip_whitespace
    self.content.strip!
  end
  
  def likes
    votes.where(:value => 1)
  end
  
  def dislikes
    votes.where(:value => -1)
  end
end
