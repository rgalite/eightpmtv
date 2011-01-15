class AddFollowsCountToSeries < ActiveRecord::Migration
  def self.up
    add_column :series, :follows_count, :integer, :default => 0
    
    Series.all.each do |serie|
      serie.update_attribute :follows_count, serie.users_followers.count
    end
  end

  def self.down
    remove_column :series, :follows_count
  end
end
