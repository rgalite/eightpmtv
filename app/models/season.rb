class Season < ActiveRecord::Base
  has_attached_file :poster, {
                    :styles => { :medium => "200x289>" },
                    :path => "seasons/:attachment/:id/:style/:basename.:extension",
                  }.merge(Tvshows::Application.config.paperclip_options)
  has_many :episodes, :dependent => :destroy, :order => "number ASC"
  belongs_to :series
  
  def poster_url=(poster_url)
    self.poster = RemoteFile.new("http://thetvdb.com/banners/#{poster_url}")
  end
end
