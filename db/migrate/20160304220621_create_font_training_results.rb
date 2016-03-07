class CreateFontTrainingResults < ActiveRecord::Migration
  def change
    create_table :font_training_results do |t|
      t.references :work, index: true
      t.references :batch_job, index: true
      t.string :path

      t.timestamps
    end
    add_index :font_training_results, [:work_id, :batch_job_id]
  end
end
