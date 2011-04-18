desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Rake::Task['db:backup'].invoke if %w{ 0 6 12 18 }.include? Time.now.hour
  Rake::Task["app:update_database_with_tvdb"].invoke(true, "day")
end