module TvdbParty
  class Series
    attr_reader :client
    attr_accessor :id, :name, :overview, :first_aired, :genres, :network, :rating, :runtime,
                  :actors, :banners, :status, :tvdb_id, :imdb_id, :language, :rating_count, :air_time,
                  :air_day, :banner, :poster, :fanart
    
    def initialize(client, options={})
      @client = client

      series_options = options["Series"]
      
      @id = series_options["id"]
      @name = series_options["SeriesName"]
      @overview = series_options["Overview"]
      @network = series_options["Network"]
      @runtime = series_options["Runtime"]
      @status = series_options["Status"]
      @imdb_id = series_options["IMDB_ID"]     
      @language = series_options["Language"]
      @rating_count = series_options["RatingCount"]
      @tvdb_id = series_options["id"]
      @air_day = series_options["Airs_DayOfWeek"]
      @air_time = series_options["Airs_Time"]
      @banner = series_options["banner"]
      @poster = series_options["poster"]
      @fanart = series_options["fanart"]
      
      if series_options["Genre"]
        @genres = series_options["Genre"][1..-1].split("|")
      else
        @genres = []
      end
      
      if series_options["Rating"] && series_options["Rating"].size > 0
        @rating = series_options["Rating"].to_f
      else
        @rating = 0
      end
            
      begin 
        @first_aired = Date.parse(series_options["FirstAired"])
      rescue
        puts "invalid date: #{series_options["FirstAired"]}"
      end
    end
    
    def get_episode(season_number, episode_number)
      client.get_episode(self, season_number, episode_number)
    end
    
    def posters(language = self.client.language)
      banners.select{|b| b.banner_type == 'poster' && b.language == language}
    end

    def fanarts(language = self.client.language)
      banners.select{|b| b.banner_type == 'fanart' && b.language == language}
    end

    def series_banners(language = self.client.language)
      banners.select{|b| b.banner_type == 'series' && b.language == language}
    end

    def season_posters(season_number = nil, language = self.client.language)
      if season_number.nil?
        banners.select{|b| b.banner_type == 'season' && b.banner_type2 == 'season' && b.language == language}
      else
        banners.select{|b| b.banner_type == 'season' && b.banner_type2 == 'season' && b.season == season_number.to_s && b.language == language}
      end
    end

    def seasonwide_posters(season_number = nil, language = self.client.language)
      if season_number.nil?
        banners.select{|b| b.banner_type == 'season' && b.banner_type2 == 'seasonwide' && b.language == language}
      else
        banners.select{|b| b.banner_type == 'season' && b.banner_type2 == 'seasonwide' && b.season == season_number.to_s && b.language == language}
      end
    end
    
    def banners
      @banners ||= client.get_banners(self) 
    end

    def actors
      @actors ||= client.get_actors(self) 
    end
    
    def season(season_number)
      seasons.detect{|s| s.number == season_number}
    end
    
    def episodes
      @episodes ||= client.get_episodes(self)
    end
  end
end
