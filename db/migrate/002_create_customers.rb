class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string :name, :null => false
      t.integer :billing_cycle_id, :null => false

      t.timestamps
    end
    
    add_foreign_key :customers, :billing_cycle_id, :billing_cycles, :id, :name => :customers_billing_cycle_id_fkey
  end

  def self.down
    drop_table :customers
  end
end
