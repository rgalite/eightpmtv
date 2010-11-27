class SessionsController < ApplicationController
  def index
    render :file => "layouts/default_yield"
  end
  
  def login
  end
  
  def logout
  end
end
