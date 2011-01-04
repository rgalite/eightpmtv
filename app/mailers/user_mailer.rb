class UserMailer < ActionMailer::Base
  default :from => "no-reply@eightpm.tv"
  
  def new_follower(user, follower)
    @user = user
    @follower = follower
    mail(:to => user.email, :subject => "#{follower.name} is now following you on 8PM.TV",
         :from => "no-reply@eightpm.tv")
  end
end
