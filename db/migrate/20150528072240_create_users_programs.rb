class CreateUsersPrograms < ActiveRecord::Migration
  def change
    create_table :users_programs do |t|

      t.timestamps null: false
    end
  end
end
