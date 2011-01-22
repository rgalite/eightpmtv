class CreateApplicationSettings < ActiveRecord::Migration
  require 'open-uri'

  def self.up
    create_table :application_settings do |t|
      t.string :last_update
      t.timestamps
    end
  end

  def self.down
    drop_table :application_settings
  end
end
