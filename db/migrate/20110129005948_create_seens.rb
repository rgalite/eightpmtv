class CreateSeens < ActiveRecord::Migration
  def self.up
    create_table :seens do |t|
      t.references :user
      t.references :seenable, :polymorphic => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :seens
  end
end
