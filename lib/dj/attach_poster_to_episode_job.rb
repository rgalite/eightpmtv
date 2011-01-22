class AttachPosterToEpisodeJob < Struct.new(:episode_id, :poster_url)
  def perform
    episode = Episode.find(episode_id)
    episode.poster = RemoteFile.new("http://thetvdb.com/banners/#{poster_url}")
    episode.save
    episode.activities.each {|act| act.update_attributes(:actor_img => episode.poster.url(:thumb)) }
    episode.inv_activities.each {|act| act.update_attributes(:subject_img => episode.poster.url(:thumb)) }
  end
end