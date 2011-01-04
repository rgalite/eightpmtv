if %w{ production staging }.include?(Rails.env)
  Delayed::Job.scaler = :heroku
else
  Delayed::Job.scaler = :local
end