class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :subject_id
      t.string :subject_name
      t.integer :term
      t.string :year

      t.timestamps null: false
    end
  end
end
