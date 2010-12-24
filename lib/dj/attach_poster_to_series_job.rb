class AttachPosterToSeriesJob < Struct.new(:series_id, :poster_url)
  def perform
    serie = Series.find(series_id)
    serie.poster = RemoteFile.new("http://thetvdb.com/banners/#{poster_url}")
    serie.save
  end
end