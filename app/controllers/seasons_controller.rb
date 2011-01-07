class SeasonsController < ApplicationController
  def show
    @season = Season.find_by_series_id_and_number(Series.find(params[:show_id]), params[:season_number])
  end

  def comment
    if user_signed_in?
      @season = Season.find(params[:id])
      @comment = @season.comments.build(:content => params[:comment][:content],
                                 :user => current_user) 
      save_comment(@comment)
    end
  end
  
  def get_poster
    @season = Season.find(params[:id])
    respond_to do |format|
      format.js do
        if @season.poster_processing?
          render :nothing => true, :status => 403
        else
          if params[:size] == "small"
            render :partial => "poster_small", :locals => { :season => @season }
          else
            render :partial => "poster", :locals => { :season => @season }
          end
        end
      end
      format.html { redirect_to show_path(@season) } # redirect to show
    end
  end
end
