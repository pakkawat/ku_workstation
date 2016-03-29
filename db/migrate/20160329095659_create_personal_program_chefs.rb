class CreatePersonalProgramChefs < ActiveRecord::Migration
  def change
    create_table :personal_program_chefs do |t|
      t.integer :personal_chef_resource_id
      t.integer :personal_program_id

      t.timestamps null: false
    end
  end
end
