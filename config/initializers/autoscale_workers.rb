if %w{ production staging }.include?(Rails.env)
  Delayed::Job.scaler = :null
else
  Delayed::Job.scaler = :null
end
