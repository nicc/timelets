class CreateBillingCycles < ActiveRecord::Migration
  def self.up
    create_table :billing_cycles do |t|
      t.string :name, :null => false
      t.integer :day_of_month, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :billing_cycles
  end
end
