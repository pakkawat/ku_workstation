class DropChef < ActiveRecord::Migration
  def change
    drop_table :chef_attributes
    drop_table :chef_resources
  end
end
