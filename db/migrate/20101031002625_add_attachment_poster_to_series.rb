class AddAttachmentPosterToSeries < ActiveRecord::Migration
  def self.up
    remove_column :series, :poster
    add_column :series, :poster_file_name, :string
    add_column :series, :poster_content_type, :string
    add_column :series, :poster_file_size, :integer
    add_column :series, :poster_updated_at, :datetime
  end

  def self.down
    add_column :series, :poster, :string
    remove_column :series, :poster_file_name
    remove_column :series, :poster_content_type
    remove_column :series, :poster_file_size
    remove_column :series, :poster_updated_at
  end
end
