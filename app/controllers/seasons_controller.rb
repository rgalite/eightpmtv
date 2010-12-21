class SeasonsController < ApplicationController
  def show
    @season = Season.find_by_series_id_and_number(Series.find(params[:show_id]), params[:season_number])
  end

end
