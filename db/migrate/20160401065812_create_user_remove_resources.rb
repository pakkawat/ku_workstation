class CreateUserRemoveResources < ActiveRecord::Migration
  def change
    create_table :user_remove_resources do |t|
      t.belongs_to :ku_user, index: true
      t.integer :personal_program_id
      t.integer :personal_chef_resource_id
      t.string :resource_type
      t.string :value
      t.string :value_type
    end
    add_foreign_key :user_remove_resources, :ku_users
  end
end
