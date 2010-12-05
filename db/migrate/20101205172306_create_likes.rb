class CreateLikes < ActiveRecord::Migration
  def self.up
    create_table :likes do |t|
      t.integer :value, :default => 0
      t.references :user
      t.references :likeable, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :likes
  end
end
