class CreateSeasons < ActiveRecord::Migration
  def self.up
    create_table :seasons do |t|
      t.integer :number
      t.integer :tvdb_id
      t.references :series
      t.timestamps
    end
    
    series = Series.all
    p "Processing series ..."
    series.each_with_index do |serie, i|
      p "Processing serie #{serie.name} (#{i+1}/#{series.size}) ..."
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      s = tvdb.get_series_by_id(serie.tvdb_id)
      
      p "Processing seasons ..."
      episodes = s.episodes
      season_number = -1
      episodes.each do |ep|
        if season_number != ep.season_number
          next if ep.season_number.zero?
          season_number = ep.season_number
          p "Processing season #{season_number} ..."
        end
        serie.seasons << Season.find_or_initialize_by_tvdb_id(ep.season_id.to_i, :number => season_number.to_i)
      end
      
      serie.save
    end
  end

  def self.down
    drop_table :seasons
  end
end
