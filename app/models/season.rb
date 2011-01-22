class Season < ActiveRecord::Base
  include HasPoster
  has_attached_file :poster, {
                    :styles => { :medium => "200x289>", :small => "150x217>" },
                    :default_url => "/images/season_default_image.png"
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
  
  def episodes_count
    episodes.size
  end
  
  def as_json(options = {})
    episodes_h = { :methods => [ :full_name ], :only => [ :full_name, :number ] }
    super(:include => {
                        :episodes => episodes_h
                      },
          :methods => [ :poster_url_small, :episodes_count ],
          :only => [ :number, :description ])
  end
end
