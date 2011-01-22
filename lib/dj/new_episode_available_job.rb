class NewEpisodeAvailableJob < Struct.new(:episode_id)
  def perform
    episode = Episode.find(episode_id)
    Activity.create!(:kind => "new_episode_available",
                      :actor_name => episode.full_name,
                      :actor => episode.series,
                      :actor_img => episode.series.poster.url(:thumb),
                      :actor_path => show_path(episode.series),
                      :subject => episode,
                      :subject_name => episode.full_name,
                      :subject_img => episode.poster.url(:thumb),
                      :subject_path => show_season_episode_path(:show_id => episode.series,
                                                                :season_number => episode.season.number,
                                                                :episode_number => episode.number),
                      :data => { :episode_description => episode.description }.to_json)
  end
end