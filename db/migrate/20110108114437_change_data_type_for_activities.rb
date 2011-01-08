class ChangeDataTypeForActivities < ActiveRecord::Migration
  def self.up
    change_column :activities, :data, :text
  end

  def self.down
    change_column :activities, :data, :string
  end
end
