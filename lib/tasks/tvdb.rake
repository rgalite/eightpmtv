namespace :tvdb do
  desc "Add series from tv database to local database"
  task :add_series => :environment do |t, args|
    unless ENV['series_list'].nil?
      series_ids = ENV['series_list'].split(',')
      series_ids.each do |series_id|
        series_db = Series.find_by_series_id(series_id.to_i)
        tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
        series_tvdb = tvdb.get_series_by_id(series_id)
        
        if series_db.nil?
          series_db = Series.new(:name => series_tvdb.name, :series_id => series_id,
                                 :description => series_tvdb.overview, :first_aired => series_tvdb.first_aired,
                                 :network => series_tvdb.network, :rating => series_tvdb.rating,
                                 :runtime => series_tvdb.runtime)
          series_db.save
        else
        end
        puts "Name = #{series_tvdb.name} ; id = #{series_tvdb.id}"
      end
    end
  end
end