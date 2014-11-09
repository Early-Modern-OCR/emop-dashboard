class CreateJobQueues < ActiveRecord::Migration
  def change
    create_table :job_queues do |t|
      t.references :batch
      t.references :page
      t.references :job_status
      t.string :results
      t.references :work
      t.string :proc_id
      t.integer :tries, default: 0

      t.timestamps
    end

    add_index :job_queues, :batch_id
    add_index :job_queues, :job_status_id
    add_index :job_queues, :page_id
    add_index :job_queues, :proc_id
    add_index :job_queues, :work_id
  end
end
