class Like < ActiveRecord::Base
  belongs_to :likeable, :polymorphic => true
  validates_inclusion_of :value, :in => %w(0 1), :allow_nil => false
  validates_uniqueness_of :user_id, :scope => [ :likeable_id, :likeable_type ]
end
