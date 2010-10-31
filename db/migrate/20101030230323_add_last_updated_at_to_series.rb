class AddLastUpdatedAtToSeries < ActiveRecord::Migration
  def self.up
    add_column :series, :last_updated_at, :datetime
  end

  def self.down
    remove_column :series, :last_updated_at
  end
end
