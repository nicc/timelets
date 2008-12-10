class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|     
      t.integer :retainer_hours
      t.boolean :retainer_includes_ah, :null => false
      t.integer :retainer_points
      t.decimal :retainer_cost
      t.decimal :oh_hourly_rate
      t.decimal :ah_hourly_rate
      t.decimal :point_rate
      t.decimal :ah_point_adjustment
      t.integer :customer_id, :null => false
      t.string :type, :null => false
      t.string :name, :null => false
      t.string :description

      t.timestamps
    end
    
    add_foreign_key :contracts, :customer_id, :customers, :id, :name => :contracts_customer_id_fkey
  end

  def self.down
    drop_table :contracts
  end
end
