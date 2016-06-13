class UpdateUserRemoveResourceAndChefFile < ActiveRecord::Migration
  def change
    remove_reference :chef_files, :chef_resource   
    remove_reference :chef_files, :personal_chef_resource  
    add_reference :personal_chef_resources, :chef_file, index: true

    remove_column :user_remove_resources, :resource_type, :string
    remove_column :user_remove_resources, :value, :string
    remove_column :user_remove_resources, :value_type, :string
    remove_column :user_remove_resources, :personal_program_id, :integer
    remove_column :user_remove_resources, :personal_chef_resource_id, :integer
    add_reference :user_remove_resources, :personal_chef_resource, index: true

    add_column :personal_chef_resources, :status, :string
  end
end
