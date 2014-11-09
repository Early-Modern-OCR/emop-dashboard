class ModifyBatchJob < ActiveRecord::Migration
  def change
    rename_table :batch_job, :batch_jobs
    rename_column :batch_jobs, :job_type, :job_type_id
    add_index :batch_jobs, :job_type_id
  end
end
