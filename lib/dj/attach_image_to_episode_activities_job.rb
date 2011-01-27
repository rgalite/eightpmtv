class AttachImageToEpisodeActivitiesJob < Struct.new(:episode_id)
  def perform
    episode = Episode.find(episode_id)
    episode.activities.each {|act| act.update_attributes(:actor_img => episode.poster.url(:thumb)) }
    episode.inv_activities.each {|act| act.update_attributes(:subject_img => episode.poster.url(:thumb)) }
  end
end