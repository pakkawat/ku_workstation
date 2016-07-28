class AddKuUserRefToPrograms < ActiveRecord::Migration
  def change
    add_reference :programs, :ku_user, index: true
    add_foreign_key :programs, :ku_users
  end
end
