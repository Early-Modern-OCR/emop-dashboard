class ModifyJobQueues < ActiveRecord::Migration
  def change
    rename_table :job_queue, :job_queues
    rename_column :job_queues, :job_status, :job_status_id
    add_index :job_queues, :job_status_id
  end
end
