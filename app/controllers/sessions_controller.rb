class SessionsController < Devise::SessionsController
  private
  def find_week_debut
  end
  
  public
  def index
    if user_signed_in?
      @activities = Activity.joins("INNER JOIN follows ON follows.followable_id = activities.actor_id AND follows.followable_type = activities.actor_type").where(["follows.follower_id = ? AND activities.created_at >= ?", current_user.id, current_user.last_sign_in_at]).order("created_at DESC")
      if @activities.size.zero?
        @activities = Activity.limit(10).joins("INNER JOIN follows ON follows.followable_id = activities.actor_id AND follows.followable_type = activities.actor_type").where(["follows.follower_id = ?", current_user.id]).order("created_at DESC")
      end
      @upcoming_episodes = current_user.series.collect { |s| s.episodes.where(["first_aired >= ? AND first_aired <= ?", Date.today, Date.today + 7.days]).limit(10).order("first_aired ASC") }.flatten.group_by {|e| e.first_aired}
    else
      @most_followed_series = Series.most_followed.limit(10)
      @last_updated_series = Series.last_updated.limit(10).order('name ASC')
      @last_activities = Activity.order("created_at DESC").limit(10)
      render "home"
    end
  end
  
  def create
    super
  end
  
  def load_activities
    activities = Activity.joins("INNER JOIN follows ON follows.followable_id = activities.actor_id AND follows.followable_type = activities.actor_type").where(["follows.follower_id = ? AND activities.id < ?", current_user.id, params[:start].to_i]).order("created_at DESC")
    @activities_count = activities.count
    @activities = activities.limit(10)
  end
  
  def new
    if !params[:message].blank?
      case params[:message] 
      when "invalid_response"
        flash[:notice] = "Could not connect to the provider"
      when "invalid_credentials"
        flash[:notice] = "Invalid credentials"
      else
        flash[:notice] = "A problem occured when connecting to the provider (#{params[:message]}). We've been noticed."
      end      
    end
    super
  end
end
