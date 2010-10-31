class AddAttachmentImageToRole < ActiveRecord::Migration
  def self.up
    remove_column :roles, :image
    add_column :roles, :image_file_name, :string
    add_column :roles, :image_content_type, :string
    add_column :roles, :image_file_size, :integer
    add_column :roles, :image_updated_at, :datetime
  end

  def self.down
    remove_column :roles, :image_file_name
    remove_column :roles, :image_content_type
    remove_column :roles, :image_file_size
    remove_column :roles, :image_updated_at
    add_column :roles, :image, :string
  end
end
