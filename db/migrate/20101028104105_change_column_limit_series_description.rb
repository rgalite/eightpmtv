class ChangeColumnLimitSeriesDescription < ActiveRecord::Migration
  def self.up
    change_column :series, :description, :string, :limit => 2048
  end

  def self.down
    change_column :series, :description, :string
  end
end
