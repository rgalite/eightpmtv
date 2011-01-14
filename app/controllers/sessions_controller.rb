class SessionsController < Devise::SessionsController
  def index
    if user_signed_in?
      @activities = Activity.joins("INNER JOIN follows ON follows.followable_id = activities.actor_id AND follows.followable_type = activities.actor_type").where(["follows.follower_id = ?", current_user.id]).order("created_at DESC")
    else
      # @most_followed_series = Series.most_followed.limit(10)
      @last_updated_series = Series.last_updated.limit(10)
      render "home"
    end
  end
end
