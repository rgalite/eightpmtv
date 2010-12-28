class Like < ActiveRecord::Base
  belongs_to :likeable, :polymorphic => true
  belongs_to :user
  validates :value, :inclusion => { :in => %w(-1 1) }
  validates :user_id, :uniqueness => { :scope => [ :likeable_id, :likeable_type ] }
end
