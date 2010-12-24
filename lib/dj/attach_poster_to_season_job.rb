class AttachPosterToSeasonJob < Struct.new(:season_id, :poster_url)
  def perform
    season = Season.find(season_id)
    season.poster = RemoteFile.new("http://thetvdb.com/banners/#{poster_url}")
    season.save
  end
end