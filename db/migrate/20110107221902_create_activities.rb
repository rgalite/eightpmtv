class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.references :actor, :polymorphic => true
      t.string :actor_path
      t.string :actor_name
      t.string :actor_img
      t.string :kind
      t.string :data
      t.timestamps
    end
    
    add_index :activities, [:actor_type, :actor_id], :name => "activities_actor_type_actor_id_ix"
    add_index :activities, :created_at, :name => "activities_created_at_ix"
  end

  def self.down
    remove_index :activities, "activities_actor_type_actor_id_ix"
    remove_index :activities, "activities_created_at_ix"
    add_index :activities, [:actor_type, :actor_id], :name => "activities_actor_type_actor_id_ix"
    drop_table :activities
  end
end
