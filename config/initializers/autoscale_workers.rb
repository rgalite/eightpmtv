Delayed::Job.auto_scale = true
if %w{ production staging }.include?(Rails.env)
  Delayed::Job.auto_scale_manager = :heroku
else
  Delayed::Job.auto_scale_manager = :local
end
