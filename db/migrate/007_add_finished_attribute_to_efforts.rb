class AddFinishedAttributeToEfforts < ActiveRecord::Migration
  def self.up
    add_column :efforts, :finished, :boolean, :default => false
  end

  def self.down
    remove_column :efforts, :finished
  end
end
