class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:follow]
  
  def index
    @users = User.order("username ASC")
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def follow
    @user = User.find(params[:id])
    if !current_user.following?(@user)
      fw = current_user.follow(@user)
      UserMailer.delay.deliver_new_follower(@user.id, current_user.id) if fw && !fw.blocked
      redirect_to user_path(@user), :notice => "Congratulations! You are now following #{@user.username}!"
      a = current_user.activities.create(:actor_path => user_path(current_user),
                                         :actor_img => current_user.photo.url(:thumb),
                                         :subject => fw,
                                         :kind => "follow_user",
                                         :data => { "user_path" => user_path(@user),
                                                    "user_name" => @user.full_name,
                                                    "user_img" => @user.photo.url(:thumb) }.to_json)
    else
      redirect_to user_path(@user), :warn => "Uh oh. It's like you're already following #{@user.username}."
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
end
