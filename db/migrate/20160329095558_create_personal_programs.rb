class CreatePersonalPrograms < ActiveRecord::Migration
  def change
    create_table :personal_programs do |t|
      t.string :program_name
      t.text :note

      t.timestamps null: false
    end
  end
end
