class AddSubjectToActivities < ActiveRecord::Migration
  def self.up
    change_table :activities do |t|
      t.references :subject, :polymorphic => true
    end
  end

  def self.down
    change_table :activities do |t|
      t.remove :subject_id
      t.remove :subject_type
    end
  end
end
