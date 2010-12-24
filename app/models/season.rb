class Season < ActiveRecord::Base
  has_attached_file :poster, {
                    :styles => { :medium => "200x289>", :small => "150x217>" },
                  }.merge(Tvshows::Application.config.paperclip_options)
  process_in_background :poster
  has_many :episodes, :dependent => :destroy, :order => "number ASC"
  belongs_to :series
  has_many :comments, :as => :commentable, :order => "created_at desc"
  
  attr_accessor :poster_url
  after_save :attach_poster
  
  def attach_poster
    Delayed::Job.enqueue(AttachPosterToSeasonJob.new(id, @poster_url), 3) unless @poster_url.nil?
  end
end
