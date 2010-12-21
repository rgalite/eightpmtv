class AddAttachmentPosterToEpisode < ActiveRecord::Migration
  def self.up
    add_column :episodes, :poster_file_name, :string
    add_column :episodes, :poster_content_type, :string
    add_column :episodes, :poster_file_size, :integer
    add_column :episodes, :poster_updated_at, :datetime
    add_column :episodes, :poster_processing, :boolean
    
    
    p "Processing series"
    Series.all.each_with_index do |serie, i|
      tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
      s = tvdb.get_series_by_id(serie.tvdb_id)
      
      p "Processing serie #{serie.name} (#{i+1}/#{Series.count})"
      p "Processing seasons"
      serie.seasons.each_with_index do |season, i|
        p "Processing season (#{season.number}/#{serie.seasons.size})"
        p "Processing episodes"
        season.episodes.each do |episode, i|
          p "Processing episode #{episode.name} (#{episode.number}/#{season.episodes.size})"
          e = s.get_episode(season.number, episode.number)
          
          unless e.nil? || e.nil?
            p e.thumb
            episode.poster_url = e.thumb
            if episode.save
              p "Saved."
            else
              p "Error when saving poster #{episode.errors.full_messages}"
            end 
          end
        end
      end 
    end
    
  end

  def self.down
    remove_column :episodes, :poster_file_name
    remove_column :episodes, :poster_content_type
    remove_column :episodes, :poster_file_size
    remove_column :episodes, :poster_updated_at
    remove_column :episodes, :poster_processing
  end
end
