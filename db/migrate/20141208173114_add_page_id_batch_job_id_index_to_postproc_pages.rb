class AddPageIdBatchJobIdIndexToPostprocPages < ActiveRecord::Migration
  def change
    add_index :postproc_pages, [:page_id, :batch_job_id], unique: true
  end
end
