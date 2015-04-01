class AddRememberDigestToKuUsers < ActiveRecord::Migration
  def change
    add_column :ku_users, :remember_digest, :string
  end
end
