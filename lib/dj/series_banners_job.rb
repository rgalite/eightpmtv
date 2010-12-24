class SeriesBannersJob < Struct.new(:series_id)
  def perform
    series = Series.find(series_id)
    tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
    s = tvdb.get_series_by_id(series.tvdb_id)
    
    s.banners.each_with_index do |banner, i|
      p "Processing banner #{i + 1}/#{s.banners.size}"
      series.banners << Banner.new(:banner_type => banner.banner_type,
                                  :data_url => banner.path,
                                  :banner_type2 => banner.banner_type2,
                                  :language => banner.language)
      p "... processed."
    end
    
    series.save
    p "Series saved"
  end
end