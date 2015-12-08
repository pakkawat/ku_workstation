class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string :log_path
      t.Boolean :error

      t.timestamps null: false
    end
  end
end
