class ModifyBatchJobs < ActiveRecord::Migration
  def change
    rename_table :batch_job, :batch_jobs
    remove_index :batch_jobs, :job_type
    rename_column :batch_jobs, :job_type, :job_type_id
    add_index :batch_jobs, :job_type_id
  end
end
