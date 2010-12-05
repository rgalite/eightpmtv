class Like < ActiveRecord::Base
  belongs_to :likeable, :polymorphic => true

  validates :value, :inclusion => { :in => %w(0 1) }
  validates :user_id, :uniqueness => { :scope => [ :likeable_id, :likeable_type ] }
end
