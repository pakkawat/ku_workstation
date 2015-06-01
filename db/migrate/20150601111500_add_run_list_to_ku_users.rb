class AddRunListToKuUsers < ActiveRecord::Migration
  def change
    add_column :ku_users, :run_list, :text
  end
end
