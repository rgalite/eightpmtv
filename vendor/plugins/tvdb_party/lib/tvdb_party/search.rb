module TvdbParty
  class Search
    include HTTParty
    include HTTParty::Icebox
    attr_accessor :language
    cache :store => 'file', :timeout => 120, :location => Dir.tmpdir
    
    base_uri 'www.thetvdb.com/api'

    def initialize(the_api_key, language = 'en')
      @api_key = the_api_key
      @language = language
    end
    
    def search(series_name)
      response = self.class.get("/GetSeries.php", {:query => {:seriesname => series_name, :language => @language}}).parsed_response
      return [] unless response["Data"]
      
      case response["Data"]["Series"]
      when Array
        response["Data"]["Series"]
      when Hash
        [response["Data"]["Series"]]
      else
        []
      end
    end
    
    def get_time
      response = self.class.get("/Updates.php", { :query => {:type => "none"} }).parsed_response
      return response["Items"]["Time"].to_i
    end
    
    def get_updates(a_time)
      response = self.class.get("/Updates.php", { :query => { :type => "all", :time => a_time } }).parsed_response
      series = response["Items"]["Series"] || []
      episodes = response["Items"]["Episodes"] || []
      b_time = response["Items"]["Time"]
      
      return series, episodes, b_time
    end
    
    def get_series_by_id(series_id, language = self.language)
      response = self.class.get("/#{@api_key}/series/#{series_id}/#{language}.xml").parsed_response
      if response["Data"] && response["Data"]["Series"]
        Series.new(self, response["Data"])
      else
        nil
      end
    end
    
    def get_episode_by_id(episode_id, language = self.language)
      response = self.class.get("/#{@api_key}/episodes/#{episode_id}/#{language}.xml").parsed_response
      if response["Data"] && response["Data"]["Episode"]
        Episode.new(response["Data"]["Episode"])
      else
        nil
      end
    end
    
    def get_episode(series, season_number, episode_number, language = self.language)
      response = self.class.get("/#{@api_key}/series/#{series.id}/default/#{season_number}/#{episode_number}/#{language}.xml").parsed_response
      if response["Data"] && response["Data"]["Episode"]
        Episode.new(response["Data"]["Episode"])
      else
        nil
      end
    end

    def get_actors(series)
      response = self.class.get("/#{@api_key}/series/#{series.id}/actors.xml").parsed_response
      if response["Actors"] && response["Actors"]["Actor"]
        response["Actors"]["Actor"].collect {|a| Actor.new(a)}
      else
        nil
      end
    end

    def get_banners(series)
      response = self.class.get("/#{@api_key}/series/#{series.id}/banners.xml").parsed_response
      return [] unless response["Banners"] && response["Banners"]["Banner"]
      case response["Banners"]["Banner"]
      when Array
        response["Banners"]["Banner"].map{|result| Banner.new(result)}
      when Hash
        [Banner.new(response["Banners"]["Banner"])]
      else
        []
      end
    end

    def get_episodes(series)
      # Get the episodes
      episodes = []
      response = self.class.get("/#{@api_key}/series/#{series.id}/all/#{language}.xml").parsed_response
      response["Data"]["Episode"].each { |episode_xml| episodes << Episode.new(episode_xml) }
      return episodes
    end
  end
end