class EpisodesController < ApplicationController
  def show
    @episode = Episode.find_by_show_id_and_season_number_and_episode_number(params[:show_id],
               params[:season_number], params[:episode_number])
    respond_to do |format|
      format.json { render :json => @episode.attributes }
      format.html
    end
  end
  
  def mark
  
  end
  
  def comment
    if user_signed_in?
      @episode = Episode.find(params[:id])
      @comment = @episode.comments.build(:content => params[:comment][:content],
                                 :user => current_user)
      series = @episode.series
      season = @episode.season 
      save_comment(@comment)
      a = current_user.activities.create(:actor_path => user_path(current_user),
                                         :actor_img => current_user.photo.url(:thumb),
                                         :subject => @comment,
                                         :subject_path => show_path(series, :anchor => "comment-#{@comment.id}"),
                                         :kind => "comment",
                                         :data => { "content" => @comment.content,
                                                    "commented_name" => @comment.commentable.full_name,
                                                    "commented_path" => show_season_episode_path(:show_id => series, :season_number => season.number, :episode_number => @episode.number) }.to_json)
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
