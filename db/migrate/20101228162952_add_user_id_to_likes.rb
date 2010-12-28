class AddUserIdToLikes < ActiveRecord::Migration
  def self.up
    add_column :likes, :user_id, :integer
    add_index :likes, :user_id, :name => "likes_user_id_ix"
  end

  def self.down
    remove_column :likes, :user_id
    remove_index :likes, "likes_user_id_ix"
  end
end
