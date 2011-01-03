class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:follow]
  
  def index
    @users = User.order("username DESC")
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def follow
    @user = User.find(params[:id])
    if !current_user.following?(@user)
      current_user.follow(@user)
      redirect_to user_path(@user), :notice => "Congratulations! You are now following #{@user.username}!"
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
end
