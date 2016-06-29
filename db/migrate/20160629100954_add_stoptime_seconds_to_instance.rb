class AddStoptimeSecondsToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :stoptime_seconds, :bigint, :default => 0
  end
end
