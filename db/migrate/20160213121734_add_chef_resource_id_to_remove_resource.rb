class AddChefResourceIdToRemoveResource < ActiveRecord::Migration
  def change
    add_column :remove_resources, :chef_resource_id, :integer
  end
end
