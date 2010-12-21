class Episode < ActiveRecord::Base
  belongs_to :season
  has_one :series, :through => :season
  has_attached_file :poster, {
                    :styles => { :medium => "200x112>" },
                  }.merge(Tvshows::Application.config.paperclip_options)
  process_in_background :poster
  
  def poster_url=(poster_url)
    self.poster = RemoteFile.new("http://thetvdb.com/banners/#{poster_url}")
  end
  
  def self.find_by_show_id_and_season_number_and_episode_number(show_id, season_number, episode_number)
    Series.find(show_id).episodes.includes(:season).where("seasons.number" => season_number,
                                                       :number => season_number).first
  end
end
