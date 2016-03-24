class AddJobIdToJobQueue < ActiveRecord::Migration
  def change
    add_column :job_queues, :job_id, :string
  end
end
