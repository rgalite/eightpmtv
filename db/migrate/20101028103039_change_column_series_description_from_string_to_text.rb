class ChangeColumnSeriesDescriptionFromStringToText < ActiveRecord::Migration
  def self.up
    change_column :series, :description, :text
  end

  def self.down
    change_column :series, :description, :string
  end
end
