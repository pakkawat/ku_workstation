class FixChefResource < ActiveRecord::Migration
  def change
    rename_column :chef_resources, :name, :resource_name
    rename_column :chef_resources, :type, :resource_type
  end
end
