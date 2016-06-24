class CreateUserErrors < ActiveRecord::Migration
  def change
    create_table :user_errors do |t|
      t.belongs_to :ku_user, index: true
      t.belongs_to :chef_resource_id, index: true
      t.belongs_to :personal_chef_resource_id, index: true
      t.integer :line_number
      t.string :log_path
      t.timestamps null: false
    end
  end
end
