class ApplicationController < ActionController::Base
  include CallRake
  protect_from_forgery
end
