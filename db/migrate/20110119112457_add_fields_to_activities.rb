class AddFieldsToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :subject_path, :string
    add_column :activities, :subject_name, :string
    add_column :activities, :subject_img, :string
    
    Activity.where(:kind => "comment").each do |a|
      a_data = JSON.parse(a.data)
      a.subject_path = a_data["path"]
      a.save
    end
  end

  def self.down
    Activity.where(:kind => "comment").each do |a|
      a_data = JSON.parse(a.data)
      a_data["path"] = a.subject_path
      a.save
    end

    remove_column :activities, :subject_img
    remove_column :activities, :subject_name
    remove_column :activities, :subject_path
  end
end
