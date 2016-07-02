class AddErrorMessageToUserErrors < ActiveRecord::Migration
  def change
    add_column :user_errors, :error_message, :string
  end
end
