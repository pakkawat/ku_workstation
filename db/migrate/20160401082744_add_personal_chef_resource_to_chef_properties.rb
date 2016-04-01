class AddPersonalChefResourceToChefProperties < ActiveRecord::Migration
  def change
    remove_reference :personal_chef_resources, :chef_property
    add_reference :chef_properties, :personal_chef_resource, index: true
    add_foreign_key :chef_properties, :personal_chef_resources
  end
end
