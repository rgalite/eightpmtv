class CreateGenreSeries < ActiveRecord::Migration
  def self.up
    create_table :genres_series, :id => false do |t|
      t.references :genre
      t.references :series
      t.timestamps
    end
    
    begin
      Series.all.each do |serie|
        p "Test #1"
        tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
        p "Test #2"
        s = tvdb.get_series_by_id(serie.tvdb_id)
        s.genres.each do |genre|
          serie.genres << Genre.find_or_initialize_by_name(genre)
        end
        if serie.save
          p "Serie #{serie.name} is saved. Genres: #{serie.genres.map(&:name).join(',')}"
        else
          p "Serie #{serie.name} could not be saved. Genres: #{serie.genres.map(&:name).join(',')}. Errors:#{serie.errors.full_messages}"
          raise "ERROR IN GENRE"
        end
      end
    rescue Exception => e
      p e
      drop_table :genres_series
      raise "Could not create genres"
    end
  end

  def self.down
    drop_table :genres_series
  end
end
