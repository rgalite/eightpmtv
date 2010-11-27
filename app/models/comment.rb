class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  
  validates_length_of :content, :in => 10..1000, :allow_nil => false
end
