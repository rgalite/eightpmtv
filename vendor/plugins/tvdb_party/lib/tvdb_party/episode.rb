module TvdbParty
  class Episode
    attr_accessor :id, :season_number, :number, :name, :overview, :air_date,
                  :guest_stars, :director, :writer, :season_id,
                  :series_id, :last_updated, :thumb
    def initialize(client, options={})
      @client = client
      @id = options["id"]
      @season_number = options["SeasonNumber"]
      @number = options["EpisodeNumber"]
      @name = options["EpisodeName"]
      @overview = options["Overview"]
      @thumb = options["filename"] if options["filename"].to_s != ""
      @director = options["Director"]
      @writer = options["Writer"]
      @season_id = options["seasonid"]
      @series_id = options["seriesid"]
      @last_updated = options["lastupdated"]

      if options["GuestStars"]
        @guest_stars = options["GuestStars"][1..-1].split("|")
      else
        @guest_stars = []
      end

      begin 
        @air_date = Date.parse(options["FirstAired"])
      rescue
        puts "invalid date: #{options["FirstAired"]}"
      end
    end
  end
end