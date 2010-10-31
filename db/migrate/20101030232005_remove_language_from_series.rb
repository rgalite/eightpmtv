class RemoveLanguageFromSeries < ActiveRecord::Migration
  def self.up
    remove_column :series, :language
  end

  def self.down
    add_column :series, :language, :string
  end
end
