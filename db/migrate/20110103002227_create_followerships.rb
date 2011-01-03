class CreateFollowerships < ActiveRecord::Migration
  def self.up
    create_table :followerships do |t|
      t.references :user
      t.references :follower

      t.timestamps
    end
    
    add_index :followerships, :user_id, :name => "followerships_user_id_ix"
    add_index :followerships, :follower_id, :name => "followerships_follower_id_ix"
  end

  def self.down
    drop_table :followerships

    remove_index :followerships, "followerships_user_id_ix"
    remove_index :followerships, "followerships_follower_id_ix"
  end
end
