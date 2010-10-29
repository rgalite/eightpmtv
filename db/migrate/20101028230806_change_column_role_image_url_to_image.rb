class ChangeColumnRoleImageUrlToImage < ActiveRecord::Migration
  def self.up
    rename_column :roles, :image_url, :image
  end

  def self.down
    rename_column :roles, :image_url, :image 
  end
end
