class UpdateDelayedjobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :subject_id, :integer
    add_column :delayed_jobs, :program_id, :integer
  end
end
