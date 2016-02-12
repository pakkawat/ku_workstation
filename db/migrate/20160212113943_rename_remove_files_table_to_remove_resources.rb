class RenameRemoveFilesTableToRemoveResources < ActiveRecord::Migration
  def change
    rename_table :remove_files, :remove_resources
    remove_column :remove_resources, :chef_resource_id, :integer
    remove_column :remove_resources, :resource_name, :string
    rename_column :remove_resources, :att_type, :value
    rename_column :remove_resources, :att_value, :value_type
  end
end
