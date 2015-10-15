class UpdateChefResourcesAndRemoveFiles < ActiveRecord::Migration
  def change
    add_column :chef_resources, :file_name, :string

    rename_column :remove_files, :chef_attribute_id, :chef_resource_id
    rename_column :remove_files, :source, :resource_type
    add_column :remove_files, :resource_name, :string
    add_column :remove_files, :att_type, :string
    add_column :remove_files, :att_value, :string
  end
end
