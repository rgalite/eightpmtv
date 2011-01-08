class Activity < ActiveRecord::Base
  belongs_to :actor, :polymorphic => true
  belongs_to :subject, :polymorphic => true
  
  validates :actor_name, :presence => true
  validates :kind, :presence => true
  validates :data, :presence => true
  validates :actor_path, :presence => true
  
  before_validation :set_actor_name
  
  def set_actor_name
    self.actor_name = actor.full_name unless actor.nil?
  end
end
