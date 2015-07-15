class AddDescriptionToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :description, :text
  end
end
