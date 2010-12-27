class CreateSeasons < ActiveRecord::Migration
  def self.up
    create_table :seasons do |t|
      t.integer :number
      t.integer :tvdb_id
      t.references :series
      t.boolean :poster_processing
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
        if !ep.season_number.to_i.zero?
          if season_number != ep.season_number
            season_number = ep.season_number
            p "Processing season #{season_number} ..."
          end

          serie.seasons << Season.new(:number => season_number.to_i,
            :tvdb_id => ep.season_id.to_i, :poster_processing => true)
        end
      end
      
      serie.save
    end
  end

  def self.down
    drop_table :seasons
  end
end
