class CreateProgramFiles < ActiveRecord::Migration
  def change
    create_table :program_files do |t|
      t.belongs_to :program, index:true
      t.string :file_path
      t.string :file_name

      t.timestamps null: false
    end
  end
end
