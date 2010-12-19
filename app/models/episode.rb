class Episode < ActiveRecord::Base
  belongs_to :season
  has_attached_file :poster, {
                    :styles => { :medium => "200x112>" },
                    :path => "episodes/:attachment/:id/:style/:basename.:extension",
                  }.merge(Tvshows::Application.config.paperclip_options)
end
