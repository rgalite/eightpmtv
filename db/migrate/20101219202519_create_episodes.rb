class CreateEpisodes < ActiveRecord::Migration
  def self.up
    create_table :episodes do |t|
      t.integer :tvdb_id
      t.references :season
      t.integer :number
      t.date :first_aired
      t.text :description
      t.string :name
      t.string :director
      t.string :writer
      t.timestamps
    end
    
    series = Series.all
    p "Processing series ..."
    series.each_with_index do |serie, i|
      p "Processing serie #{i+1}/#{series.size} ..."
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      s = tvdb.get_series_by_id(serie.tvdb_id)
      
      p "Processing episodes ..."
      episodes = s.episodes
      episodes.each_with_index do |ep, j|
        p "Processing episode #{j+1}/#{episodes.size} ..."
        season = Season.find_by_number_and_tvdb_id(ep.season_number.to_i, ep.season_id.to_i)        
        season.episodes << Episode.new(:tvdb_id => ep.id, :number => ep.number,
                              :name => ep.name, :description => ep.overview,
                              :director => ep.director, :writer => ep.writer)
        season.save
      end
    end
  end

  def self.down
    drop_table :episodes
  end
end
