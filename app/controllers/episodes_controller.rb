class EpisodesController < ApplicationController
  def show
    @episode = Episode.find_by_show_id_and_season_number_and_episode_number(params[:show_id],
               params[:season_number], params[:episode_number])
  end
  
  def mark
  
  end
  
  def comment
    if user_signed_in?
      @episode = Episode.find(params[:id])
      @comment = @episode.comments.build(:content => params[:comment][:content],
                                 :user => current_user) 
      save_comment(@comment)
    end
  end
  
  def get_poster
    @episode = Episode.find(params[:id])
    respond_to do |format|
      format.js do
        if @episode.poster_processing?
          render :nothing => true, :status => 403
        else
          render :partial => "poster", :locals => { :episode => @episode }
        end
      end
      format.html { redirect_to episode_path(@episode) } # redirect to show
    end
  end
end
