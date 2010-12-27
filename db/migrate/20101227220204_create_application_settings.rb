class CreateApplicationSettings < ActiveRecord::Migration
  require 'open-uri'

  def self.up
    create_table :application_settings do |t|
      t.string :last_update
      t.timestamps
    end
    
    tvdb = TvdbParty::Search.new(Tvshows::Application.config.the_tv_db_api_key)
    ApplicationSetting.create!(:last_update => tvdb.get_time())
  end

  def self.down
    drop_table :application_settings
  end
end
