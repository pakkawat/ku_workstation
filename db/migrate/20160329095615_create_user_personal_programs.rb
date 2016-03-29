class CreateUserPersonalPrograms < ActiveRecord::Migration
  def change
    create_table :user_personal_programs do |t|
      t.integer :ku_user_id
      t.integer :personal_program_id
      t.string :status

      t.timestamps null: false
    end
  end
end
