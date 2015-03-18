class CreateKuUsers < ActiveRecord::Migration
  def change
    create_table :ku_users do |t|
      t.string :ku_id
      t.string :username
      t.string :password_digest
      t.string :firstname
      t.string :lastname
      t.integer :sex
      t.string :email
      t.integer :degree_level
      t.integer :faculty
      t.integer :major_field
      t.integer :status

      t.timestamps null: false
    end
  end
end
