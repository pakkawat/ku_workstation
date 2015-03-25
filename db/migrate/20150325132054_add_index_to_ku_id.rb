class AddIndexToKuId < ActiveRecord::Migration
  def change
    add_index :ku_users, :ku_id, unique: true
  end
end
