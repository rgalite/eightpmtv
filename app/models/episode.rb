class Episode < ActiveRecord::Base
  include ActiveModel::Serializers::JSON
  include HasPoster
  belongs_to :season
  has_one :series, :through => :season
  has_attached_file :poster, {
                    :styles => { :small => "200x112>", :medium => "300x168>", :thumb => "172x97>" },
                    :default_url => "/images/episode_default_image.png",
                  }.merge(Tvshows::Application.config.paperclip_options)
  process_in_background :poster
  has_many :comments, :as => :commentable, :order => "created_at desc"
  
  attr_reader :poster_url
  after_save :attach_poster
  named_scope :available, :conditions => [ "episodes.first_aired IS NOT NULL AND episodes.first_aired <= ? AND episodes.updated_at >= ?", Date.today, Time.at(ApplicationSetting.last_update.to_i).to_date]
  
  def self.find_by_show_id_and_season_number_and_episode_number(show_id, season_number, episode_number)
    Series.find(show_id).episodes.includes(:season).where("seasons.number" => season_number,
                                                       :number => episode_number).first
  end
  
  def attach_poster
    Delayed::Job.enqueue(AttachPosterToEpisodeJob.new(id, @poster_url), { :priority => 4 }) unless @poster_url.nil?
  end
  
  def poster_url=(value)
    @poster_url = value
    self.poster_processing = !value.blank?
  end
  
  def available?
    aired? && updated_at.to_date >= first_aired # Time.at(Settings.last_update.to_i).to_date
  end
  
  def available_before?(date)
    aired_before?(date) && updated_at.to_date >= first_aired # Time.at(Settings.last_update.to_i).to_date
  end
  
  def aired_before?(date)
    !first_aired.nil? && first_aired < date
  end
  
  def aired?
    !first_aired.nil? && first_aired <= Date.today
  end
  
  def full_name
    @full_name ||= "#{series.name} S#{season.number.to_s.rjust(2, '0')}E#{number.to_s.rjust(2, '0')} - #{self.name}"
  end
  
  def previous
    if @previous.nil?
      cur_index = series.episodes.find_index(self)
      @previous = series.episodes[cur_index - 1] unless cur_index.zero?
    end
    @previous
  end
  
  def next
    @next ||= series.episodes[series.episodes.find_index(self) + 1]
  end
end
