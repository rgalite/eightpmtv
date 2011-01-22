class AttachPosterToSeriesJob < Struct.new(:series_id, :poster_url)
  def perform
    serie = Series.find(series_id)
    serie.poster = RemoteFile.new("http://thetvdb.com/banners/#{poster_url}")
    serie.save
    
    serie.activities.each {|act| act.update_attributes(:actor_img => serie.poster.url(:thumb)) }
    serie.inv_activities.each {|act| act.update_attributes(:subject_img => serie.poster.url(:thumb)) }
  end
end