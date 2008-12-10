class DropIdFromRolesUsers < ActiveRecord::Migration
  def self.up
    remove_column :roles_users, :id
  end

  def self.down
    add_column :roles_users, :id, :integer
  end
end
