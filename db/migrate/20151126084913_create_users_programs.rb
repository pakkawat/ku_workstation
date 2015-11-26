class CreateUsersPrograms < ActiveRecord::Migration
  def change
    create_table :users_programs do |t|
      t.belongs_to :ku_user, index: true
      t.belongs_to :program, index: true
      t.string :subject_id
    end
  end
end
