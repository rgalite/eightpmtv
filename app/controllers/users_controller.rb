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
    if !@user.followers.include?(current_user)
      @user.followers << current_user 
      @user.save!
      redirect_to user_path(@user), :notice => "Congratulations! You are now following #{@user.username}!"
    else
      redirect_to user_path(@user), :warn => "Uh oh. It's like you're already following #{@user.username}"
    end
  end
end
