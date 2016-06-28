class UpdateUserErrors2 < ActiveRecord::Migration
  def change
    add_column :user_errors, :chef_resource_id, :integer
    add_column :user_errors, :personal_chef_resource_id, :integer
  end
end
