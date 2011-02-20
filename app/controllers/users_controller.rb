class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:follow]
  
  def index
    @users = User.order("username ASC")
    @page_title = "Community"    
    
    respond_to do |format|
      format.json { render :json => @users }
      format.html
    end
  end
  
  def show
    @user = User.find(params[:id])
    @page_title = @user.full_name
    
    respond_to do |format|
      format.json do
        render :json => @user.as_json_with_followers_and_followings
        end
                                                  
      format.html
    end
  end
  
  def follow
    @user = User.find(params[:id])
    if !current_user.following?(@user)
      fw = current_user.follow(@user)
      UserMailer.delay.deliver_new_follower(@user.id, current_user.id) if fw && !fw.blocked
      redirect_to user_path(@user), :notice => "Congratulations! You are now following #{@user.username}!"
      a_data = {}
      a_data[:user_path] = user_path(@user)
      a_data[:user_name] = @user.full_name
      a_data[:user_img] = @user.photo.url(:thumb)
                 
      # Get the series the user is following
      a_data[:user_series] = @user.series.all.randomly_pick(5).collect{ |serie| { :name => serie.full_name, :path => show_path(serie) } }
      a_data[:user_series_count] = @user.series.count

      # Get the people who are following the user
      a_data[:user_followers] = @user.followers.randomly_pick(5).collect{ |follower| { :name => follower.full_name, :path => user_path(follower), :img => follower.avatar_url(:thumb) } }
      a_data[:user_followers_count] = @user.followers.count

      # Get the people the user is following
      a_data[:user_followings] = @user.following_by_type('User').randomly_pick(5).collect{ |follower| { :name => follower.full_name, :path => user_path(follower), :img => follower.avatar_url(:thumb) } }
      a_data[:user_followings_count] = @user.following_by_type('User').count

      a = current_user.activities.create!(:actor_path => user_path(current_user),
                                          :actor_img => current_user.photo.url(:thumb),
                                          :subject => fw,
                                          :kind => "follow_user",
                                          :data => a_data.to_json)
    end
  end
  
  def unfollow
    @user = User.find(params[:id])
    if current_user.following?(@user)
      
      current_user.stop_following(@user)
      redirect_to user_path(@user), :notice => "You are not following #{@user.username} anymore."
    else
      redirect_to user_path(@user), :warn => "You are not following #{@user.username}."
    end
  end
  
  def name
    redirect_to users_path
  end
  
  def block
  end
  
  def unblock
  end
  
  def followers  
  end
end
