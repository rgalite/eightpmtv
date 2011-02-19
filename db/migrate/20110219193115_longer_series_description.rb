class LongerSeriesDescription < ActiveRecord::Migration
  def self.up
    change_column :series, :description, :string, :limit => 3072
  end

  def self.down
    change_column :series, :description, :string, :limit => 2048
  end
end
