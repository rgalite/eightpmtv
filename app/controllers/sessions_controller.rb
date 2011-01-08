class SessionsController < ApplicationController
  def index
    if user_signed_in?
      @activities = Activity.joins("INNER JOIN follows ON follows.followable_id = activities.actor_id AND follows.followable_type = activities.actor_type").where(["follows.follower_id = ?", current_user.id])
    else
      render :file => "layouts/default_yield"
    end
  end
  
  def login
  end
  
  def logout
  end
end
