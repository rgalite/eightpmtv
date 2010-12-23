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
      c = @episode.comments.build(:content => params[:comment][:content],
                                 :user => current_user) 
      save_comment(c)
    end
  end
end
