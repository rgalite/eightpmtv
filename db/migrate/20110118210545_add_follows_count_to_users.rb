class AddFollowsCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :follows_count, :integer
  end

  def self.down
    remove_column :users, :follows_count
  end
end
