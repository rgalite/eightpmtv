class AddAttachmentPosterToSeason < ActiveRecord::Migration
  def self.up
    add_column :seasons, :poster_file_name, :string
    add_column :seasons, :poster_content_type, :string
    add_column :seasons, :poster_file_size, :integer
    add_column :seasons, :poster_updated_at, :datetime
    add_column :seasons, :poster_processing, :boolean
    
    series = Series.all
    p "Processing series ..."
    series.each_with_index do |serie, i|
      p "Processing serie #{serie.name} (#{i+1}/#{series.size}) ..."
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      s = tvdb.get_series_by_id(serie.tvdb_id)
      
      p "Processing seasons ..."
      seasons = serie.seasons
      seasons.each do |season|
        p "Processing season #{season.number}/#{seasons.size} ..."
        season.poster_url = s.season_posters(season.number).first.path unless s.season_posters(season.number).first.nil?
        p "Has poster ? #{!season.poster.nil?}"
        season.save
      end
    end
  end

  def self.down
    remove_column :seasons, :poster_file_name
    remove_column :seasons, :poster_content_type
    remove_column :seasons, :poster_file_size
    remove_column :seasons, :poster_updated_at
    remove_column :seasons, :poster_processing
  end
end
