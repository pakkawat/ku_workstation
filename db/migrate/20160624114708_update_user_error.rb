class UpdateUserError < ActiveRecord::Migration
  def change
    rename_column :user_errors, :chef_resource_id_id, :chef_resource_id
    rename_column :user_errors, :personal_chef_resource_id_id, :personal_chef_resource_id
  end
end
