class Season < ActiveRecord::Base
  has_attached_file :poster, {
                    :styles => { :medium => "200x289>", :small => "150x217>" },
                  }.merge(Tvshows::Application.config.paperclip_options)
  process_in_background :poster
  has_many :episodes, :dependent => :destroy, :order => "number ASC"
  belongs_to :series
  has_many :comments, :as => :commentable, :order => "created_at desc"
  
  attr_reader :poster_url
  after_save :attach_poster
  
  def attach_poster
    Delayed::Job.enqueue(AttachPosterToSeasonJob.new(id, @poster_url), { :priority => 2 }) unless @poster_url.nil?
  end
  
  def poster_url=(value)
    @poster_url = value
    self.poster_processing = !value.blank?
  end
  
  def full_name
    @full_name ||= "#{series.full_name} S#{number.to_s.rjust(2, '0')}"
  end
end
