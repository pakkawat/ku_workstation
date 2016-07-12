class AddIndexeChefAttributeToPersonalChefResource < ActiveRecord::Migration
  def change
    add_reference :chef_attributes, :personal_chef_resource
    add_index :chef_attributes, :personal_chef_resource_id
  end
end
