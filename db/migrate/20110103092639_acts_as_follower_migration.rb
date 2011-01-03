class ActsAsFollowerMigration < ActiveRecord::Migration
  def self.up
    create_table :follows, :force => true do |t|
      t.references :followable, :polymorphic => true, :null => false
      t.references :follower,   :polymorphic => true, :null => false
      t.boolean :blocked, :default => false, :null => false
      t.timestamps
    end

    add_index :follows, ["follower_id", "follower_type"],     :name => "fk_follows"
    add_index :follows, ["followable_id", "followable_type"], :name => "fk_followables"
    drop_table :subscriptions
    drop_table :followerships
    drop_table :friendships
  end

  def self.down
    create_table :subscriptions do |t|
      t.integer :series_id
      t.integer :user_id

      t.timestamps
    end
    create_table :followerships do |t|
      t.references :user
      t.references :follower

      t.timestamps
    end
    create_table :friendships do |t|
      t.references :user
      t.references :friend
      t.timestamps
    end
    
    drop_table :follows
  end
end
