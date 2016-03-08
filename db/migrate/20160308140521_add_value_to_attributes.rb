class AddValueToAttributes < ActiveRecord::Migration
  def change
    add_column :attributes, :value, :string
  end
end
