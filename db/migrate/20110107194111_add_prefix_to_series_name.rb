class AddPrefixToSeriesName < ActiveRecord::Migration
  def self.up
    add_column :series, :name_prefix, :string, :default => ""
    
    Series.all.find_all { |s| s.name.downcase.starts_with?('the ') }.each do |serie|
      p "Found serie #{serie.name}"
      serie.update_attributes({ :name_prefix => "The", :name => serie.name.gsub(/^The\s+/, "")})
    end
  end

  def self.down
    Series.all.find_all {|s| !s.name_prefix.blank? }.each do |serie|
      p "Found serie #{serie.full_name}"
      serie.update_attributes({ :name => serie.full_name })
    end
    remove_column :series, :name_prefix, :string
  end
end
