class Seen < ActiveRecord::Base
  belongs_to :user
  belongs_to :seenable, :polymorphic => true
end
