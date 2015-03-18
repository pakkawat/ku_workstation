class AddCampusToKuUser < ActiveRecord::Migration
  def change
    add_column :ku_users, :campus, :integer
  end
end
