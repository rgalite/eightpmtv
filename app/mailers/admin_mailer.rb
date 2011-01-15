class AdminMailer < ActionMailer::Base
  default :from => "no-reply@eightpm.tv"
  
  def series_update_succeeded(results)
    @results = results
    @follower = User.find(follower_id)
        
    mail(:to => "rudth.mael.galite@gmail.com",
         :subject => "The series have been updated successfully on 8PM.TV")
  end

  def series_update_failed(error)
    @error = error
        
    mail(:to => "rudth.mael.galite@gmail.com",
         :subject => "An error occurred when updating the series on 8PM.TV")
  end

end
