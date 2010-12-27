class AddPosterProcessingToSeries < ActiveRecord::Migration
  def self.up
    add_column :series, :poster_processing, :boolean
  end

  def self.down
    remove_column :series, :poster_processing
  end
end
