class Series < ActiveRecord::Base
  include ActiveModel::Serializers::JSON
  include HasPoster
  has_many :roles, :dependent => :destroy
  has_many :actors, :through => :roles, :order => "name ASC"
  has_many :comments, :as => :commentable, :order => "created_at desc"
  has_friendly_id :full_name, :use_slug => true, :approximate_ascii => true,
                  :max_length => 50
  has_and_belongs_to_many :genres, :order => "name ASC"
  has_attached_file :poster, {
                      :styles => { :small => "150x220#", :medium => "204x300#", :thumb => "100x147#" },
                    }.merge(Tvshows::Application.config.paperclip_options)
  has_many :likes, :as => :likeable, :dependent => :destroy
  has_many :seasons, :dependent => :destroy, :order => "seasons.number ASC"
  has_many :episodes, :through => :seasons, :dependent => :destroy
  has_many :activities, :dependent => :destroy, :as => :actor
  process_in_background :poster
  after_save :attach_poster
  after_create :attach_episodes
  attr_reader :poster_url
  acts_as_followable
  scope :most_followed, :order => "follows_count DESC, name ASC", :conditions => ["status = ?", true]
  scope :last_updated,  :conditions => ["updated_at > ? AND status = ?", 3.days.ago, true],
                        :order => "updated_at DESC, name ASC"
  
  public  
  
  def set_actors(actors)
    actors.each_with_index do |a, i|
      actor = Actor.find_or_initialize_by_name(:name => a.name, :tvdb_id => a.id)
      role = Role.new(:actor => actor, :name => a.role, :image_url => a.image)
      self.roles << role if role.valid?
    end
  end
      
  def attach_poster
    Delayed::Job.enqueue(AttachPosterToSeriesJob.new(id, @poster_url), { :priority => 0 }) unless @poster_url.blank?
  end
  
  def attach_episodes
    Delayed::Job.enqueue(SeriesEpisodesJob.new(id), { :priority => 3 })
    # Delayed::Job.enqueue(SeriesActorsJob.new(id))
  end
  
  def poster_url=(value)
    @poster_url = value
    self.poster_processing = !value.blank?
  end
  
  def watchers
    self.user_followers
  end
  
  def full_name
    @full_name ||= (name_prefix.blank? ? name : "#{name_prefix} #{name}")
  end
  
  def name=(value)
    if value.downcase.starts_with?('the ')
      @name_prefix = "The"
    end
    super
  end
  
  def as_json(options={})
    super(:include => [:episodes, :seasons],
          :methods => [:poster_url_small, :poster_url_medium, :poster_url_thumb, :poster_url_original])
  end
end
