class UpdateChefAttribute < ActiveRecord::Migration
  def change
    remove_reference :chef_attributes, :chef_property 
    add_reference :chef_attributes, :chef_resource
  end
end
