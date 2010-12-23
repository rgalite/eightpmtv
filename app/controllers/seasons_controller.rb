class SeasonsController < ApplicationController
  def show
    @season = Season.find_by_series_id_and_number(Series.find(params[:show_id]), params[:season_number])
  end

  def comment
    if user_signed_in?
      @season = Season.find(params[:id])
      c = @season.comments.build(:content => params[:comment][:content],
                                 :user => current_user) 
      save_comment(c)
    end
  end
end
