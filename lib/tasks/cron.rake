desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Rake::Task["app:update_database_with_tvdb"].invoke(true)
end