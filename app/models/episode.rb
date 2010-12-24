class Episode < ActiveRecord::Base
  belongs_to :season
  has_one :series, :through => :season
  has_attached_file :poster, {
                    :styles => { :small => "200x112>", :medium => "300x168>" },
                  }.merge(Tvshows::Application.config.paperclip_options)
  process_in_background :poster
  has_many :comments, :as => :commentable, :order => "created_at desc"
  
  attr_accessor :poster_url
  after_save :attach_poster
  
  def self.find_by_show_id_and_season_number_and_episode_number(show_id, season_number, episode_number)
    Series.find(show_id).episodes.includes(:season).where("seasons.number" => season_number,
                                                       :number => episode_number).first
  end
  
  def attach_poster
    Delayed::Job.enqueue(AttachPosterToEpisodeJob.new(id, @poster_url), :priority => 4) unless @poster_url.nil?
  end
end
