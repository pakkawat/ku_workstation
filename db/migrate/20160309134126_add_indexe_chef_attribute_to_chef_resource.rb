class AddIndexeChefAttributeToChefResource < ActiveRecord::Migration
  def change
    add_index :chef_attributes, :chef_resource_id
  end
end
