class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
   	  t.belongs_to :ku_user, index: true
      t.string :log_path
      t.boolean :error

      t.timestamps null: false
    end
  end
end
