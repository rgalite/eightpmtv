module TvdbParty
  class Series
    attr_reader :client
    attr_accessor :id, :name, :overview, :seasons, :first_aired, :genres, :network, :rating, :runtime,
                  :actors, :banners, :status, :tvdb_id, :imdb_id, :language, :rating_count, :air_time,
                  :air_day, :banner, :poster, :fanart
    
    def initialize(client, options={})
      @client = client

      @id = options["id"]
      @name = options["SeriesName"]
      @overview = options["Overview"]
      @network = options["Network"]
      @runtime = options["Runtime"]
      @status = options["Status"]
      @imdb_id = options["IMDB_ID"]     
      @language = options["Language"]
      @rating_count = options["RatingCount"]
      @tvdb_id = options["id"]
      @air_day = options["Airs_DayOfWeek"]
      @air_time = options["Airs_Time"]
      @banner = options["banner"]
      @poster = options["poster"]
      @fanart = options["fanart"]
      
      if options["Genre"]
        @genres = options["Genre"][1..-1].split("|")
      else
        @genres = []
      end
      
      if options["Rating"] && options["Rating"].size > 0
        @rating = options["Rating"].to_f
      else
        @rating = 0
      end
      
      begin 
        @first_aired = Date.parse(options["FirstAired"])
      rescue
        puts 'invalid date'
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

    def seasons
      @seasons ||= client.get_seasons(self) 
    end

    def actors
      @actors ||= client.get_actors(self) 
    end
    
    def season(season_number)
      seasons.detect{|s| s.number == season_number}
    end
    
  end
end
