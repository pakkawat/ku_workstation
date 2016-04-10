class AddOwnerToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :owner, :integer
  end
end
