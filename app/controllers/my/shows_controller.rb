class My::ShowsController < ApplicationController
  def index
    @shows = current_user.series.order("name ASC") if current_user
  end
  
  def show
    @show = Series.find(params[:id])
    @unseen_episodes = @show.episodes.available.unseen_by(current_user)
  end
end
