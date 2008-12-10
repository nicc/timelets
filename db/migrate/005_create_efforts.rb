class CreateEfforts < ActiveRecord::Migration
  def self.up
    create_table :efforts do |t|
      t.datetime :start, :null => false
      t.datetime :stop
      t.integer :duration
      t.datetime :billed_on
      t.string :ticket_reference
      t.string :name, :null => false
      t.integer :contract_id
      t.integer :user_id, :null => false
      t.integer :hourly_point_value, :null => false

      t.timestamps
    end
    
    add_foreign_key :efforts, :contract_id, :contracts, :id, :name => :efforts_contract_id_fkey
    add_foreign_key :efforts, :user_id, :users, :id, :name => :efforts_user_id_fkey
  end

  def self.down
    drop_table :efforts
  end
end
