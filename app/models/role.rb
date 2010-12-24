class Role < ActiveRecord::Base
  belongs_to :series
  belongs_to :actor
  
  has_friendly_id :name, :use_slug => true, :approximate_ascii => true,
                  :max_length => 50, :scope => :series

  validates_presence_of :name

  has_attached_file :image, {
                    :styles => { :small => "100x150>" },
                    :path => "assets/roles/:attachment/:id/:style/:basename.:extension",
                  }.merge(Tvshows::Application.config.paperclip_options)
  
  has_many :likes, :as => :likeable
  has_many :comments, :as => :commentable, :order => "created_at desc"

  process_in_background :image
  attr_accessor :image_url
  
  def after_save
    Delayed::Job.enqueue(AttachImageToRoleJob.new(id, @image_url)) unless @image_url.nil?
  end
end
