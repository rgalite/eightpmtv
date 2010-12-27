class CreateFriendships < ActiveRecord::Migration
  def self.up
    drop_table :friendships
    create_table :friendships do |t|
      t.references :user
      t.references :friend
      t.timestamps
    end
  end

  def self.down
    drop_table :friendships
  end
end
