class CreateUserSubjects < ActiveRecord::Migration
  def change
    create_table :user_subjects do |t|
      t.string :ku_id
      t.string :subject_id
      t.references :ku_user, index: true
      t.references :subject, index: true

      t.timestamps null: false
    end
    add_foreign_key :user_subjects, :ku_users
    add_foreign_key :user_subjects, :subjects
  end
end
