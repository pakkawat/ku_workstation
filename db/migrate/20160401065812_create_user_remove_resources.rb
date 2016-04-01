class CreateUserRemoveResources < ActiveRecord::Migration
  def change
    create_table :user_remove_resources do |t|

      t.timestamps null: false
    end
  end
end
