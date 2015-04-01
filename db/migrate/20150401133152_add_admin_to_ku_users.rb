class AddAdminToKuUsers < ActiveRecord::Migration
  def change
    add_column :ku_users, :admin, :boolean, default: false
  end
end
