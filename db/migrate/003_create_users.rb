class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name, :null => false
      t.string :email, :null => false
      t.integer :point_value, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
