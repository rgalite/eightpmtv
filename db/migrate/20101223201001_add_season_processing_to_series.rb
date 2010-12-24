class AddSeasonProcessingToSeries < ActiveRecord::Migration
  def self.up
    add_column :series, :seasons_processing, :boolean
  end

  def self.down
    remove_column :series, :seasons_processing
  end
end
