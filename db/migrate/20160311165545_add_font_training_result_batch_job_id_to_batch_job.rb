class AddFontTrainingResultBatchJobIdToBatchJob < ActiveRecord::Migration
  def change
    add_column :batch_jobs, :font_training_result_batch_job_id, :integer
  end
end
