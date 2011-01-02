class UsersController < ApplicationController
  def index
    @users = User.order("username DESC")
  end
end
