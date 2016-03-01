class CreateBashScripts < ActiveRecord::Migration
  def change
    create_table :bash_scripts do |t|
      t.text :bash_script_content
      t.timestamps null: false
    end
  end
end
