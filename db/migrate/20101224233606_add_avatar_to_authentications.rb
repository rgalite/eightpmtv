class AddAvatarToAuthentications < ActiveRecord::Migration
  def self.up
    add_column :authentications, :avatar, :string
  end

  def self.down
    remove_column :authentications, :avatar
  end
end
