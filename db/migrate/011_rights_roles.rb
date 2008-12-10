class RightsRoles < ActiveRecord::Migration
  def self.up
    create_table :rights_roles, :id => false do |t|
      t.integer :right_id
      t.integer :role_id

      t.timestamps
    end
  end

  def self.down
    drop_table :rights_roles
  end
end
